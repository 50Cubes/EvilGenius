<?php

require_once('JoshAndrew/backend/Predis/lib/Predis/Autoloader.php');
require_once('JoshAndrew/backend/mutexHandler.php');
Predis\Autoloader::register();
$redis = new Predis\Client();
$redis->select(9);

$mysqli = new mysqli("localhost", "admin", "fiddy", "evilgenius");
if ($mysqli->connect_errno) {
  echo "{'error':-2,'message':'Failed to connect to MySQL: (" . $mysqli->connect_errno . ") " . $mysqli->connect_error . "'}";
  exit(-2);
}

$MAX_PLAYERS = 3;
$response = array();

switch ($_REQUEST['method'])
{
  case 'Match':
    $userId = $_REQUEST['user_id'];
    $userName = isset($_REQUEST['user_name']) ? $_REQUEST['user_name'] : 'User '.$userId;
    $mutex = new RedisMutex($redis);
    
    //YOU SHALL NOT PASS!!!
    $mutex->block($userId, 'match');
    
    $currentMatchId = intval($redis->get('current-match-id'));
    $currentMatchPlayers = $redis->lrange('match-players-'.$currentMatchId, 0, -1);
    $numMatchPlayers = count($currentMatchPlayers);
    $players = array();
    
    if ($numMatchPlayers < $MAX_PLAYERS)
    {
      foreach($currentMatchPlayers as $player)
      {
        $playerInfo = explode('-', $player);
        if ($userId == $playerInfo[1])
        {
          echo "{'error': -1}";
          exit(1);
        }
       
        $players[] = array('user_id' => $playerInfo[1], 'user_name' => $playerInfo[3], 'play_type' => "orator");
      }
    }
    
    $playType = $numMatchPlayers == $MAX_PLAYERS-1 ? "judge" : "orator";
    
    if ($playType == "judge")
    {
      $redis->set('match-judge-index-'.$currentMatchId, $MAX_PLAYERS-1);
    }
    
    $response['play_type'] = $playType;
    $response['player_info'] = $players;
    
    if ($numMatchPlayers == $MAX_PLAYERS)
    {
      $currentMatchId++;
      $redis->set('current-match-id', $currentMatchId);
      $numMatchPlayers = 0;
      
      $res = $mysqli->query('select text from adlib order by rand()');
      for ($i = 0; $i < $res->num_rows; $i++)
      {
        $res->data_seek($i);
        $row = $res->fetch_assoc();
        $redis->lpush('adlib-deck-match-'.$currentMatchId, $row['text']);
      }
      
      $response['adlib'] = $redis->rpop('adlib-deck-match-'.$currentMatchId);
      $redis->lpush('adlib-deck-match-'.$currentMatchId, $response['adlib']);
      $redis->set('match-adlib-'.$currentMatchId, $response['adlib']);
      
      $res = $mysqli->query('select * from answers order by rand()');
      for ($i = 0; $i < $res->num_rows; $i++)
      {
        $res->data_seek($i);
        $row = $res->fetch_assoc();
        $redis->lpush('answer-deck-match-'.$currentMatchId, 'answerId-'.$row['id'].'-score-'.$row['score']);
      }
    }
    else
    {
      $response['adlib'] = $redis->get('match-adlib-'.$currentMatchId);
    }
    
    $response['hand'] = array();
    
    for ($i = 0; $i < 10; $i++)
    {
      $answerCard = $redis->rpop('answer-deck-match-'.$currentMatchId);
      $redis->lpush('answer-deck-match-'.$currentMatchId, $answerCard);
      $redis->lpush('answer-hand-match-'.$currentMatchId.'-user-'.$userId, $answerCard);
      $answerCardInfo = explode('-', $answerCard);
      $answerCardData['id'] = $answerCardInfo[1];
      $answerCardData['score'] = $answerCardInfo[3];
      
      $res = $mysqli->query('select text from answers where id='.$answerCardData['id']);
      $row = $res->fetch_assoc();
      $answerCardData['text'] = $row['text'];
      
      $response['hand'][] = $answerCardData;
    }
    
    $redis->lpush('match-players-'.$currentMatchId, 'userId-'.$userId.'-userName-'.$userName);
    
    $response['match_id'] = $currentMatchId;
    
    $mutex->unlock($userId, 'match');
    //ok u pas nao
  break;
  case 'PingForFullMatch':
    $matchId = $_REQUEST['match_id'];
    $numPlayers = $redis->llen('match-players-'.$matchId);
    
    $ready = $numPlayers == $MAX_PLAYERS;
    $response['ready'] = intval($ready);
    if ($numPlayers > 0)
    {
      $matchPlayers = $redis->lrange('match-players-'.$matchId, 0, -1);
      $response['player_info'] = array();
      
      $judgeIndex = $redis->get('match-judge-index-'.$matchId);
      $playerIndex = 0;
      
      foreach($matchPlayers as $player)
      {
        $playerInfo = explode('-', $player);
        $response['player_info'][] = array('user_id' => $playerInfo[1], 'user_name' => $playerInfo[3], 'play_type' => $judgeIndex==$playerIndex ? "judge" : "orator");
        $playerIndex++;
      }
    }
  break;
  case 'AnswerAdlib':
    $userId = $_REQUEST['user_id'];
    $chosenAnswerId = $_REQUEST['answer_id'];
    $matchId = $_REQUEST['match_id'];
    
    $numAnswers = $redis->llen('match-answers-'.$matchId);
    $response['ready'] = intval($numAnswers == $MAX_PLAYERS - 1);
    if ($numAnswers > 0)
    {
      $answers = $redis->lrange('match-answers-'.$matchId, 0, -1);
      $response['answers'] = array();
      
      foreach ($answers as $answer)
      {
        $answerInfo = explode('-', $answer);
        $answerId = $answerInfo[3];
        $res = $mysqli->query('select text from answers where id = '.$answerId);
        $row = $res->fetch_assoc();
        
        $response['answers'][] = array('user_id' => $answerInfo[1], 'answer_id' => $answerInfo[3], 'answer_text' => $row['text']);
      }
    }
    
    $hand = $redis->lrange('answer-hand-match-'.$matchId.'-user-'.$userId, 0, -1);
    
    foreach ($hand as $answerCard)
    {
      $answerCardInfo = explode('-', $answerCard);
      $answerCardId = $answerCardInfo[1];
      $answerCardScore = $answerCardInfo[3];
      
      if ($answerCardId == $chosenAnswerId)
      {
        $redis->lrem('answer-hand-match-'.$matchId.'-user-'.$userId, 1, $answerCard);
        $redis->lpush('answer-deck-match-'.$matchId, $answerCard);
        $answerCard = $redis->rpop('answer-deck-match-'.$matchId);
        $answerCardInfo = explode('-', $answerCard);
        $answerCardId = $answerCardInfo[1];
        $answerCardScore = $answerCardInfo[3];
        $redis->lpush('answer-hand-match-'.$matchId.'-user-'.$userId, $answerCard);
      }
      
      $res = $mysqli->query('select text from answers where id='.$answerCardId);
      $row = $res->fetch_assoc();
      $response['hand'] = array('id' => $answerCardId, 'score' => $answerCardScore, 'text' => $row['text']);
    }
    
    $redis->lpush('match-answers-'.$matchId, 'userId-'.$userId.'-answerId-'.$chosenAnswerId);
  break;
  case 'PingForAnswers':
    $matchId = $_REQUEST['match_id'];
    
    $numAnswers = $redis->llen('match-answers-'.$matchId);
    $response['ready'] = intval($numAnswers == $MAX_PLAYERS - 1);
    if ($numAnswers > 0)
    {
      $answers = $redis->lrange('match-answers-'.$matchId, 0, -1);
      $response['answers'] = array();
      
      foreach ($answers as $answer)
      {
        $answerInfo = explode('-', $answer);
        $answerId = $answerInfo[3];
        $res = $mysqli->query('select text from answers where id = '.$answerId);
        $row = $res->fetch_assoc();
        $response['answers'][] = array('user_id' => $answerInfo[1], 'answer_id' => $answerInfo[3], 'answer_text' => $row['text']);
      }
    }
  break;
  case 'JudgeSelect':
    $matchId = $_REQUEST['match_id'];
    $chosenAnswerId = $_REQUEST['answer_id'];
    $userId = $_REQUEST['user_id'];
    error_log('match: '.$matchId.' answer: '.$chosenAnswerId.' user: '.$userId);
    
    $redis->set('match-judgment-'.$matchId, 'userId-'.$userId.'-answerId-'.$chosenAnswerId);
    
    $answers = $redis->lrange('match-answers-'.$matchId, 0, -1);
    
    foreach ($answers as $answer)
    {
      $answerInfo = explode('-', $answer);
      $answerUserId = $answerInfo[1];
      $answerId = $answerInfo[3];
      error_log('answer: '.$answer);
      
      if ($res = $mysqli->query('select score from answers where id = '.$answerId))
      {
        $row = $res->fetch_assoc();
        $score = $row['score'];
        error_log('score: '.$score);
          
        if (!$mysqli->query('update player set score=score'.($chosenAnswerId == $answerId ? '+' : '-').$score.' where user_id='.$answerUserId))
        {
          $mysqli->query('insert into player (user_id, score) values ('.$answerUserId.', '.(1000 + $score * ($chosenAnswerId == $answerId ? 1 : -1)).')');
        }
      }
    }
    
    if ($res = $mysqli->query('select score from player where user_id='.$userId))
    {
      $row = $res->fetch_assoc();
      if (!$row['score'])
      {
        $mysqli->query('insert into player (user_id, score) values ('.$userId.', 1000.1)');
        $score = 1000.1;
        error_log('new user score: '.$score);
      }
      else
      {
        $score = $row['score'] + .1;
        error_log('found user score: '.$score);
        $mysqli->query('update player set score='.$score.' where user_id='.$userId);
      }
    }
    
    $response['adlib'] = $redis->rpop('adlib-deck-match-'.$matchId);
    $redis->lpush('adlib-deck-match-'.$matchId, $response['adlib']);
    $redis->set('match-adlib-'.$matchId, $response['adlib']);
    
    $judgeIndex = $redis->get('match-judge-index-'.$matchId);
    if ($judgeIndex < $MAX_PLAYERS-1)
    {
      $judgeIndex++;
    }
    else
    {
      $judgeIndex = 0;
    }
    $redis->set('match-judge-index-'.$matchId, $judgeIndex);
    
    $response['score'] = floor($score);
  break;
  case 'PingForJudgment':
    $matchId = $_REQUEST['match_id'];
    $userId = $_REQUEST['user_id'];
    
    $judgment = $redis->get('match-judgment-'.$matchId);
    
    if ($judgment)
    {
      $response['ready'] = 1;
      $judgmentInfo = explode('-', $judgment);
      $answerId = $judgmentInfo[3];
      $res = $mysqli->query('select text from answers where id = '.$answerId);
      $answerRow = $res->fetch_assoc();
      
      $res = $mysqli->query('select score from player where user_id='.$userId);
      $playerRow = $res->fetch_assoc();
      $response['judgment'] = array('user_id' => $judgmentInfo[1], 'answer_id' => $judgmentInfo[3], 'answer_text' => $answerRow['text'], 'score' => floor($playerRow['score']));
      $response['adlib'] = $redis->get('match-adlib-'.$matchId);
      
      //Determine if this player is the new judge
      $newJudgeIndex = $redis->get('match-judge-index-'.$matchId);
      error_log('new judge index: '.$newJudgeIndex);
      $judgePlayer = $redis->lindex('match-players-'.$matchId, $newJudgeIndex);
      error_log('new judge: '.$judgePlayer);
      $judgePlayerInfo = explode('-', $judgePlayer);
      error_log('judge user id: '.$judgePlayerInfo[1]);
      error_log('user: '.$userId);
      $response['judge'] = intval(intval($judgePlayerInfo[1]) == intval($userId));
    }
    else
    {
      $response['ready'] = 0;
    }
  break;
  case 'GetPlayerScore':
    $userId = $_REQUEST['user_id'];
    if ($res = $mysqli->query('select score from player where user_id = '.$userId))
    {
      if ($res->num_rows > 0)
      {
        $row = $res->fetch_assoc();
        $response['score'] = $row['score'];
      }
      else
      {
        $mysqli->query('insert into player (user_id) values ('.$userId.')');
        $response['score'] = 1000;
      }
    }
  break;
  default:
    $response = "{'error': -2}";
  break;
}

$mysqli->close();
error_log('response: '.print_r($response, 1));
echo json_encode($response);

?>
