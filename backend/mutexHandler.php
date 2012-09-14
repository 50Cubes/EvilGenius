<?php
class RedisMutex  {

  function RedisMutex($redisClient)
  {
    $this->_redisClient = $redisClient;
  }

  /**
  * The number of seconds before this mutex will automatically expire
  * @var integer
  */
  public $expiresAfter = 5;

  /**
  * The number of micro seconds to sleep for between poll requests.
  * Defaults to half a second.
  * @var integer
  */
  public $pollDelay = 500000;

  /**
  * The time the mutex expires at
  * @var integer
  */
  protected $_expiresAt;
  
  protected $_redisClient;

  /**
  * Attempts to lock the mutex, returns true if successful or false if the mutex is locked by another process.
  * @return boolean whether the lock was successful or not
  */
  public function lock($userId, $mutexId) {
    //error_log('testing the door: '.$userId.'-'.$this->getExpiresAt(true) );
    if (!$this->_redisClient->setnx($mutexId, $userId.'-'.$this->getExpiresAt(true))) {
      // see if this mutex has expired
      //error_log('door is locked by someone else');
      $values = explode('-', $this->_redisClient->get($mutexId));
      if (isset($values[1]))
      {
        $expireTime = $values[1];
        if ($expireTime <= microtime(true)) {
          $this->_redisClient->del($mutexId);
        }
      }
      
      return false;
    }
    return true;
  }
  /**
  * Attempts to unlock the mutex, returns true if successful, or false if the mutex is in use by another process
  * @return boolean whether the unlock was successful or not
  */
  public function unlock($userId, $mutexId) {
    //error_log('trying to unlock');
    $values = explode('-', $this->_redisClient->get($mutexId));
    $lockUserId = $values[0];
    if ($lockUserId != $userId) {
      return false;
    }

    return $this->_redisClient->del($mutexId);
  }
  /**
  * Blocks program execution until the lock becomes available
  * @return ARedisMutex $this after the lock is opened
  */
  public function block($userId, $mutexId) {
    //error_log('trying to block');
    while($this->lock($userId, $mutexId) === false) {
      usleep($this->pollDelay);
    }
    return $this;
  }

  /**
  * Gets the time the mutex expires
  * @param boolean $forceRecalculate whether to force recalculation or not
  * @return float the time the mutex expires
  */
  public function getExpiresAt($forceRecalculate = false)
  {
    if ($forceRecalculate || $this->_expiresAt === null) {
      $this->_expiresAt = $this->expiresAfter + microtime(true);
    }
    return $this->_expiresAt;
  }
}
