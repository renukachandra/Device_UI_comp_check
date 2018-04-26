*** Settings ***
Library    Process
Library    AppiumLibrary
Library    Collections
Library    Dialogs
Library    Adb.py

*** Variables ***
#EDIT THESE VALUES ACCORDING TO YOUR PHONE
${number}    9871988989
${extratap}    true
${automationName}    uiautomator2
${platformVersion}    8.1
${appPackage}     com.google.android.dialer
${appActivity}    com.google.android.dialer.extensions.GoogleDialtactsActivity
${udid}    PLEGAR1762222343
${platformName}    android
${appium_url}    http://localhost:4723/wd/hub
${dialpad_0}    com.google.android.dialer:id/zero
${dialpad_1}    com.google.android.dialer:id/one
${dialpad_2}    com.google.android.dialer:id/two
${dialpad_3}    com.google.android.dialer:id/three
${dialpad_4}    com.google.android.dialer:id/four
${dialpad_5}    com.google.android.dialer:id/five
${dialpad_6}    com.google.android.dialer:id/six
${dialpad_7}    com.google.android.dialer:id/seven
${dialpad_8}    com.google.android.dialer:id/eight
${dialpad_9}    com.google.android.dialer:id/nine
${callbutton}    com.google.android.dialer:id/dialpad_floating_action_button
${sms_app}    com.google.android.apps.messaging
${sms_activity}    com.google.android.apps.messaging.ui.ConversationListActivity
${send_button}    com.google.android.apps.messaging:id/send_message_button_icon
${merge_call}    //android.widget.LinearLayout[contains(@content-desc,'Merge call')]
${add_call}    //android.widget.LinearLayout[contains(@content-desc,'Add call')]
${hold_call}    //android.widget.LinearLayout[contains(@content-desc,'Hold call')]
${resume_call}    //android.widget.LinearLayout[contains(@content-desc,'Resume call')]
${phonetab}    com.google.android.dialer:id/floating_action_button
${number_input_fw_busy}    android:id/edit
${dialerinput}    com.google.android.dialer:id/digits
${call_fw_busy_turnon_button}    //android.widget.Button[contains(@text,'TURN ON')]
${CFB_update}    //android.widget.Button[contains(@text,'UPDATE')]
${call_fw_busy_turnoff_button}    //android.widget.Button[contains(@text,'TURN OFF')]

#inputs for this script only
${recipient1}    9810761494  #add 1st mobile number for calling
${recipient2}    8448277411  #add 2nd mobile number for calling

*** Test Cases ***
test calling
    start dialer
    make call    ${recipient1}
    drop call
    Pause Execution    message=make a call to this phone and click 'OK'
    check answer
    Pause Execution    message=make a call to this phone and click 'OK'
    check reject
    Pause Execution    message=make a call to this phone and click 'OK'
    check hold and unhold
    Pause Execution    message=make a call to this phone and click 'OK'
    check add and merge call
    [Teardown]    drop call

test sms
    send sms

test airplane mode enable/disable
    Attach
    sleep    5s
    Detach
    [Teardown]    Close settings    ${udid}

test call forwarding when busy enable/disable
    Activate call forwarding when busy
    sleep    5s
    Deactivate call forwarding when busy
    [Teardown]    Close settings    ${udid}

test call waiting enable/disable
    Activate call waiting
    sleep    5s
    Deactivate call waiting
    [Teardown]    Close settings    ${udid}

*** keywords ***
start dialer
    Open Application    ${appium_url}    platformName=android    platformVersion=${platformVersion}
     ...    deviceName=${udid}    udid=${udid}    automationName=${automationName}
     ...    appPackage=${appPackage}    newCommandTimeout=2500    appActivity=${appActivity}    autoGrantPermissions=True
    Run keyword if    '${extratap}' == 'true'    Click element    ${phonetab}

make call
    [Arguments]    ${recipient}
    @{mylist_mobileno}    Convert To List    ${recipient}
    @{list}=    Create List    ${dialpad_0}    ${dialpad_1}    ${dialpad_2}
     ...    ${dialpad_3}    ${dialpad_4}    ${dialpad_5}    ${dialpad_6}
     ...    ${dialpad_7}    ${dialpad_8}    ${dialpad_9}
    : FOR    ${element}    IN    @{mylist_mobileno}
    \    ${index}=    Evaluate    ${element}
    \    ${number}=    Get From List    ${list}    ${index}
    \    Click element    ${number}
    Click element    ${callbutton}
    sleep    10s

drop call
    End call    ${udid}

check answer
    Answer call    ${udid}
    sleep    10s
    End call    ${udid}

check reject
    End call    ${udid}

send sms
    start sms app
    Compose SMS    ${udid}    ${recipient1}    test
    sleep    3s
    Click Element    ${send_button}

start sms app
    Open Application    ${appium_url}    platformName=android    platformVersion=${platformVersion}
    ...    deviceName=${udid}    udid=${udid}    automationName=uiautomator2
    ...    appPackage=${sms_app}    newCommandTimeout=2500    appActivity=${sms_activity}

check hold and unhold
    Answer call    ${udid}
    Pause Execution    message=bring the phone to in call screen if already not and click 'OK'
    ${present}=  Run Keyword And Return Status    Element Should Be Visible   ${more_options}
    Run Keyword If    ${present}    Click Element    ${more_options}
    ...    ELSE    Click Element    ${hold_call}
    sleep    2s
    Run Keyword If    ${present}    Click Element    ${select_hold}
    sleep    10s
    ${present}=  Run Keyword And Return Status    Element Should Be Visible   ${more_options}
    Run Keyword If    ${present}    Click Element    ${more_options}
    ...    ELSE    Click Element    ${resume_call}
    sleep    2s
    Run Keyword If    ${present}    Click Element    ${select_resumecall}
    sleep    5s
    End call    ${udid}

check add and merge call
    Answer call    ${udid}
    Pause Execution    message=bring the phone to in call screen if already not and click 'OK'
    Click Element    ${add_call}
    sleep    3s
    make call    ${recipient2}
    Click Element    ${merge_call}

Attach
    ${Android_version}=  get android version number    ${udid}
    Run keyword if   ${Android_version} < 7.0    Set Network Connection Status    connectionStatus=4
    Run keyword if   ${Android_version} >= 7.0    disable airplane on android 7

disable airplane on android 7
    launch_airplane_mode_settings   ${udid}
    sleep    5s
    ${status}    Run keyword and return status    Click Text    Airplane mode  exact_match=True
    Run keyword if    not ${status}    Click Text    Aeroplane mode  exact_match=True


Detach
    ${Android_version}=  get android version number    ${udid}
    Run keyword if   ${Android_version} < 7.0    Set Network Connection Status    connectionStatus=1
    Run keyword if   ${Android_version} >= 7.0    Enable airplane on android 7

Enable airplane on android 7
    launch_airplane_mode_settings    ${udid}
    sleep    5s
    ${status}    Run keyword and return status    Click Text    Airplane mode  exact_match=True
    Run keyword if    not ${status}    Click Text    Aeroplane mode  exact_match=True

Activate call forwarding when busy
    Open call forwarding settings    ${udid}
    Click Element    //android.widget.TextView[contains(@text,'busy')]
    Clear Text    ${number_input_fw_busy}
    Input Text    ${number_input_fw_busy}     ${recipient1}
    ${turnon_button_present}    Run Keyword And Return Status    Element Should Be Visible   ${call_fw_busy_turnon_button}
    Run Keyword If    ${turnon_button_present}    Click Element    ${call_fw_busy_turnon_button}
    ...    ELSE    Click Element    ${CFB_update}

Deactivate call forwarding when busy
    Open call forwarding settings    ${udid}
    Click Element    //android.widget.TextView[contains(@text,'busy')]
    Click Element    ${call_fw_busy_turnoff_button}

Activate call waiting
    ${present}=  Run Keyword And Return Status    Element Should Be Visible   ${dialpad_1}
    Run Keyword If    not ${present}    Start dialer
    ${number}    Get call wait on number    ${udid}
    dial number    ${number}
    sleep    5s
    Click Text    OK    exact_match=True

Deactivate call waiting
    ${present}=  Run Keyword And Return Status    Element Should Be Visible   ${dialpad_1}
    Run Keyword If    not ${present}    Start dialer
    ${number}    Get call wait off number    ${udid}
    dial number    ${number}
    sleep    5s
    Click Text    OK    exact_match=True


dial number
    [Arguments]    ${value}
    Clear Text    ${dialerinput}
    Input Text    ${dialerinput}    ${value}
    Click element    ${callbutton}