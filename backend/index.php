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
    $answerId = $_REQUEST['answer_id'];
    $answerText = $_REQUEST['answer_text'];
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
        $response['answers'][] = array('user_id' => $playerInfo[1], 'answer_id' => $playerInfo[3], 'answer_text' => $playerInfo[5]);
      }
    }
    
    $redis->lpush('match-answers-'.$matchId, 'userId-'.$userId.'-answerId-'.$answerId.'-answerText-'.$answerText);
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
        $response['answers'][] = array('user_id' => $playerInfo[1], 'answer_id' => $playerInfo[3], 'answer_text' => $playerInfo[5]);
      }
    }
  break;
  case 'JudgeAnswers':
    $matchId = $_REQUEST['match_id'];
    $answerId = $_REQUEST['answer_id'];
    $answerText = $_REQUEST['answer_text'];
    
    $redis->set('match-judgment-'.$matchId, 'answerId-'.$answerId.'-answerText-'.$answerText);
    $response = array('ok' => 'yay!');
  break;
  case 'PingForJudgment':
    $matchId = $_REQUEST['match_id'];
    
    $judgment = $redis->get('match-judgment-'.$matchId);
    
    if ($judgment)
    {
      $response['ready'] = true;
      $judgmentInfo = explode('-', $judgment);
      $response['judgment'] = array('answer_id' => $judgmentInfo[1], 'answer_text' => $judgmentInfo[3]);
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

echo json_encode($response);

?>
