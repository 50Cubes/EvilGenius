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
    $hasJudge = false;
    $players = array();
    
    foreach($currentMatchPlayers as $player)
    {
      $playerInfo = explode('-', $player);
      if ($userId == $playerInfo[1])
      {
        echo "{'error': -1}";
        exit(1);
      }
     
      $players[] = array('user_id' => $playerInfo[1], 'user_name' => $playerInfo[3], 'play_type' => $playerInfo[5]);
    }
    
    $numMatchPlayers = count($currentMatchPlayers);
    $playType = $numMatchPlayers == $MAX_PLAYERS-1 && !$hasJudge ? "judge" : "orator";
    $response['play_type'] = $playType;
    $response['player_info'] = $players;
    
    if ($numMatchPlayers == $MAX_PLAYERS)
    {
      $currentMatchId++;
      $redis->set('current-match-id', $currentMatchId);
      $numMatchPlayers = 0;
      
      
      $res = $mysqli->query('select text from adlib order by rand() limit 1');
      $row = $res->fetch_assoc();
      $response['adlib'] = $row['text'];
      $redis->set('match-adlib-'.$currentMatchId, $response['adlib']);
    }
    else
    {
      $response['adlib'] = $redis->get('match-adlib-'.$currentMatchId);
    }
    
    if ($playType == "orator")
    {
      $res = $mysqli->query('select * from answers order by rand() limit 10');
      $response['hand'] = array();
      
      for ($i = 0; $i < $res->num_rows; $i++)
      {
        $res->data_seek($i);
        $response['hand'][] = $res->fetch_assoc();
      }
    }
    
    $redis->lpush('match-players-'.$currentMatchId, 'userId-'.$userId.'-userName-'.$userName.'-role-'.$playType);
    
    $response['match_id'] = $currentMatchId;
    
    $mutex->unlock($userId, 'match');
    //ok u pas nao
  break;
  case 'PingForFullMatch':
    $matchId = $_REQUEST['match_id'];
    $numPlayers = $redis->llen('match-players-'.$matchId);
    
    $ready = $numPlayers == $MAX_PLAYERS;
    $response['ready'] = $ready;
    if ($numPlayers > 0)
    {
      $matchPlayers = $redis->lrange('match-players-'.$matchId, 0, -1);
      $response['players'] = array();
      
      foreach($matchPlayers as $player)
      {
        $playerInfo = explode('-', $player);
        $response['players'][] = array('user_id' => $playerInfo[1], 'user_name' => $playerInfo[3], 'play_type' => $playerInfo[5]);
      }
    }
  break;
  case 'AnswerAdlib':
    $userId = $_REQUEST['user_id'];
    $chosenAnswerId = $_REQUEST['answer_id'];
    $matchId = $_REQUEST['match_id'];
    
    $numAnswers = $redis->llen('match-answers-'.$matchId);
    $response['ready'] = $numAnswers == $MAX_PLAYERS - 1;
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
    
    $redis->lpush('match-answers-'.$matchId, 'userId-'.$userId.'-answerId-'.$chosenAnswerId);
  break;
  case 'PingForAnswers':
    $matchId = $_REQUEST['match_id'];
    
    $numAnswers = $redis->llen('match-answers-'.$matchId);
    $response['ready'] = $numAnswers == $MAX_PLAYERS - 1;
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
  case 'JudgeAnswers':
    $matchId = $_REQUEST['match_id'];
    $chosenAnswerId = $_REQUEST['answer_id'];
    $userId = $_REQUEST['user_id'];
    
    $redis->set('match-judgment-'.$matchId, 'userId-'.$userId.'-answerId-'.$answerId);
    
    $answers = $redis->lrange('match-answers-'.$matchId, 0, -1);
    
    foreach ($answers as $answer)
    {
      $answerInfo = explode('-', $answer);
      $answerUserId = $answerInfo[1];
      $answerId = $answerInfo[3];
      
      if ($res = $mysqli->query('select score from answer where id = '.$answerId))
      {
        $row = $res->fetch_assoc();
        $score = $row['score'];
          
        if (!$mysqli->query('update player set score=score'.($chosenAnswerId == $answerId ? '+' : '-').$score.' where user_id='.$answerUserId))
        {
          $mysqli->query('insert into player (user_id, score) values ('.$answerUserId.', '.(1000 + $score * ($chosenAnswerId == $answerId ? 1 : -1)).')');
        }
      }
    }
    
    if ($res = $mysqli->query('select score from player where user_id='.$userId))
    {
      $row = $res->fetch_assoc();
      $score = $row['score'] + .1;
      $mysqli->query('update player set score='.$score.' where user_id='.$userId);
    }
    else
    {
      $mysqli->query('insert into player (user_id, score) values ('.$userId.', 1000.1)');
      $score = 1000.1;
    }
    
    $response = array('score' => floor($score));
  break;
  case 'PingForJudgment':
    $matchId = $_REQUEST['match_id'];
    $userId = $_REQUEST['user_id'];
    
    $judgment = $redis->get('match-judgment-'.$matchId);
    
    if ($judgment)
    {
      $response['ready'] = true;
      $judgmentInfo = explode('-', $judgment);
      $answerId = $playerInfo[3];
      $res = $mysqli->query('select text from answers where id = '.$answerId);
      $answerRow = $res->fetch_assoc();
      
      $res = $mysqli->query('select score from player where user_id='.$user_id);
      $playerRow = $res->fetch_assoc();
      $response['judgment'] = array('user_id' => $judgmentInfo[1], 'answer_id' => $judgmentInfo[3], 'answer_text' => $answerRow['text'], 'score' => floor($playerRow['score']));
    }
    else
    {
      $response['ready'] = false;
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
echo json_encode($response);

?>
