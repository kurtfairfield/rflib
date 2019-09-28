/*
 * Copyright (c) 2019 Johannes Fischer <fischer.jh@gmail.com>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of mosquitto nor the names of its
 *    contributors may be used to endorse or promote products derived from
 *    this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */
@isTest
@SuppressWarnings('PMD.ClassNamingConventions')
public class rflib_DefaultLoggerTest {

  @isTest
  public static void testDefaultBehaviour() {
    rflib_DefaultLoggerTest.DebugLogCapture debugLogCapture = new rflib_DefaultLoggerTest.DebugLogCapture();
    rflib_DefaultLoggerTest.EventCapture eventCapture = new rflib_DefaultLoggerTest.EventCapture();
    
    rflib_Logger logger = new rflib_DefaultLogger(
      eventCapture,
      debugLogCapture, 
      'testDefaultBehaviour');

    logger.debug('debug statement to ignore');
    logger.info('first info statement');

    Integer i;
    for (i = 2; i < 101; i++) {
      logger.info('info statement ' + i);
    }

    logger.error('error statement');

    System.assert(eventCapture.eventHasNotBeenPublished(), 'event should not have been published');

    System.assert(debugLogCapture.doesNotContainInAnyMessage('debug statement to ignore'), 'falsely contained debug statement to ignore');
    System.assert(debugLogCapture.containsInAnyMessage('first info statement'), 'debugLogger did not contain statement');
    System.assert(debugLogCapture.containsInAnyMessage('error statement'), 'debugLogger did not contain statement');

    debugLogCapture.clearCapturedLogs();

    logger.printLogs();

    System.assert(debugLogCapture.containsInAnyMessage('Log statements reported by'), 'debugLogger did not contain header statement'); 
    System.assert(debugLogCapture.doesNotContainInAnyMessage('first info statement'), 'debugLogger falsely contained statement');
    System.assert(debugLogCapture.containsInAnyMessage('error statement'), 'debugLogger did not contain statement');

    logger.fatal('fatal log statement');

    System.assert(eventCapture.eventHasBeenPublished(), 'event did not get published');
    System.assert(eventCapture.doesNotContainInAnyMessage('first info statement'), 'event falsely contained statement');
    System.assert(eventCapture.containsInAnyMessage('error statement'), 'event did not contain statement');
    System.assert(eventCapture.containsInAnyMessage('fatal log statement'), 'event did not contain statement');
  }

  @isTest
  public static void testSetLogCacheSize() {
    rflib_DefaultLoggerTest.DebugLogCapture debugLogCapture = new rflib_DefaultLoggerTest.DebugLogCapture();
    rflib_DefaultLoggerTest.EventCapture eventCapture = new rflib_DefaultLoggerTest.EventCapture();
    
    rflib_Logger logger = new rflib_DefaultLogger(
      eventCapture,
      debugLogCapture, 
      'testSetLogCacheSize');

    logger.setLogCacheSize(3);

    logger.info('first info statement');

    Integer i;
    for (i = 2; i < 5; i++) {
      logger.info('info statement ' + i);
    }

    System.assert(debugLogCapture.containsInAnyMessage('first info statement'), 'debugLogger did not contain statement');
    System.assert(debugLogCapture.containsInAnyMessage('info statement 4'), 'debugLogger did not contain statement');

    debugLogCapture.clearCapturedLogs();
    logger.printLogs();

    System.assert(debugLogCapture.doesNotContainInAnyMessage('first info statement'), 'debugLogger falsely contained statement');
    System.assert(debugLogCapture.containsInAnyMessage('info statement 4'), 'debugLogger did not contain statement');

    logger.fatal('fatal log statement');

    System.assert(eventCapture.eventHasBeenPublished(), 'event did not get published');
    System.assert(eventCapture.doesNotContainInAnyMessage('first info statement'), 'event falsely contained statement');
    System.assert(eventCapture.containsInAnyMessage('fatal log statement'), 'event did not contain statement');
  }

  @isTest
  public static void testSetSystemLoggingLevel() {
    rflib_DefaultLoggerTest.DebugLogCapture debugLogCapture = new rflib_DefaultLoggerTest.DebugLogCapture();
    rflib_DefaultLoggerTest.EventCapture eventCapture = new rflib_DefaultLoggerTest.EventCapture();
    
    rflib_Logger logger = new rflib_DefaultLogger(
      eventCapture,
      debugLogCapture, 
      'testSetLogCacheSize');

    logger.debug('debug statement to ignore');
    System.assert(debugLogCapture.doesNotContainInAnyMessage('debug statement to ignore'), 'falsely contained debug statement to ignore');

    logger.setSystemDebugLevel(rflib_LogLevel.DEBUG);

    logger.debug('debug statement to include');
    System.assert(debugLogCapture.containsInAnyMessage('debug statement to include'), 'debugLogger did not contain statement');
  }

  @isTest
  public static void testSetReportingLogLevel() {
    rflib_DefaultLoggerTest.DebugLogCapture debugLogCapture = new rflib_DefaultLoggerTest.DebugLogCapture();
    rflib_DefaultLoggerTest.EventCapture eventCapture = new rflib_DefaultLoggerTest.EventCapture();
    
    rflib_Logger logger = new rflib_DefaultLogger(
      eventCapture,
      debugLogCapture, 
      'testSetReportingLogLevel');

    logger.error('This statement should NOT trigger the publishing of an event');
    System.assert(eventCapture.eventHasNotBeenPublished());

    logger.setReportingLogLevel(rflib_LogLevel.ERROR);

    logger.error('This statement should trigger the publishing of an event');
    System.assert(eventCapture.eventHasBeenPublished());
  }

  @isTest
  public static void testMessageWithArgs() {
    rflib_DefaultLoggerTest.DebugLogCapture debugLogCapture = new rflib_DefaultLoggerTest.DebugLogCapture();
    rflib_DefaultLoggerTest.EventCapture eventCapture = new rflib_DefaultLoggerTest.EventCapture();
    
    rflib_Logger logger = new rflib_DefaultLogger(
      eventCapture,
      debugLogCapture, 
      'testMessageWithArgs');

    logger.warn('warn message including {0}', new String[] { 'foo'});
    System.assert(debugLogCapture.containsInAnyMessage('warn message including foo'), 'debugLogger did not contain statement');
  }

  @isTest
  public static void testCreateFromCustomSettings() {
    insert new rflib_Logger_Settings__c(
      Log_Size__c = 50,
      System_Debug_Log_Level__c = 'warn',
      Log_Event_Reporting_Level__c = 'error'
    );

    System.assert(rflib_DefaultLogger.createFromCustomSettings('logger') != null);
  }

  @isTest
  public static void testCreateCreate() {
    System.assert(rflib_DefaultLogger.create('logger') != null);
  }

  public class DebugLogCapture implements rflib_DefaultLogger.DebugLogger {
    private final List<String> capturedLogMessages = new List<String>();
    
    public void debug(LoggingLevel level, String message) {
      capturedLogMessages.add(message);
    }

    public void clearCapturedLogs() {
      capturedLogMessages.clear();
    }

    public Boolean doesNotContainInAnyMessage(String substring) {
      for (String message : capturedLogMessages) {
        if (message.contains(substring)) {
          System.debug('Actual messages:\n' + String.join(capturedLogMessages, '\n'));
          return false;
        }
      }

      return true;
    }

    public Boolean containsInAnyMessage(String substring) {
      for (String message : capturedLogMessages) {
        if (message.contains(substring)) {
          return true;
        }
      }

      System.debug('Actual messages:\n' + String.join(capturedLogMessages, '\n'));
      return false;
    }
  }

  public class EventCapture implements rflib_DefaultLogger.EventPublisher {
    private rflib_Log_Event__e capturedEvent;

    public void publish(SObject event) {
      capturedEvent = (rflib_Log_Event__e) event;
    } 

    public Boolean eventHasNotBeenPublished() {
      return capturedEvent == null;
    }

    public Boolean eventHasBeenPublished() {
      return capturedEvent != null;
    }

    public Boolean doesNotContainInAnyMessage(String substring) {
      Boolean result = capturedEvent.Log_Messages__c.contains(substring);
      if (result) {
        System.debug('Actual event message:\n' + capturedEvent.Log_Messages__c);
      }
      return result == false;
    }

    public Boolean containsInAnyMessage(String substring) {
      Boolean result = capturedEvent.Log_Messages__c.contains(substring);
      if (!result) {
        System.debug('Actual event message:\n' + capturedEvent.Log_Messages__c);
      }
      return result;
    }
  }
}