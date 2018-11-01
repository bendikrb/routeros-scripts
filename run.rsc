:global TeliaAPIConfig
:if (!any $TeliaAPIConfig) do={
  :system script run "TeliaAPI"
}
:global TeliaAPISendSMS

:local msgs [:tool sms inbox find where message~$cmd];
:local sms [:tool sms inbox get [[:pick $msgs ([:len $msgs]-1)]]];
:local phone ("\"" . $sms->"phone" . "\"")

:log info ("Running CMD: $cmd from " . $phone)
:local runCmd [:parse $cmd]
:local result [$runCmd]

:if ($result != "") do={
  :log info "Sending reply"
  :local msg [:tostr $result]
  [$TeliaAPISendSMS numbers=$phone message=$msg save=true]
} else={
  :log info "No reply"
}
