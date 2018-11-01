:global powerstate
:global voltage
:set voltage [/system health get voltage]
:local voltageFormatted (($voltage / 10) . "." . [:pick $voltage [:len ($voltage / 10)]])
#:local smsAlertNumbers {"+4791773395";"+4799999999";"+4799999999"}
:local smsAlertNumbers "\"4799999999\""
:local smsMessages {
  "on_battery"="Ruteren har mistet nett-str\\u00f8m og g\\u00e5r n\\u00e5 p\\u00e5 batteri. V=$voltageFormatted"
  "normal"="Ruteren er n\\u00e5 tilkoblet nett-str\\u00f8m, og batteriet lades. V=$voltageFormatted"
}

:global TeliaAPIConfig
:if (!any $TeliaAPIConfig) do={
  :system script run "TeliaAPI"
}
:global TeliaAPISendSMS
:global TeliaAPIUnload

:local isOnBattery do={
  :global voltage
  :return ($voltage <= $threshold)
}

# Set initial state
:if ($powerstate = "") do={
  if ([$isOnBattery threshold=160]) do={
    :set powerstate "on_battery"
  } else={
    :set powerstate "normal"
  }
}

:local smsAlert do={
  [$TeliaAPISendSMS message=$message numbers=([:toarray $numbers])]
  #:foreach num in=[:toarray $numbers] do={
  #  :log info "Sending SMS to $num ..."
  #  :tool sms send lte1 "$num" message="$message"
  #}
}

:if ([$isOnBattery threshold=160]) do={
  if ($powerstate != "on_battery") do={
    :log info "Voltage monitor: Changed state to ON_BATTERY!"
    :set powerstate "on_battery"
    [$TeliaAPISendSMS numbers=$smsAlertNumbers message=($smsMessages->"on_battery")]
  }
} else={
  if ($powerstate != "normal") do={
    :log info "Voltage monitor: Changed state back to NORMAL!"
    :set powerstate "normal"
    [$TeliaAPISendSMS numbers=$smsAlertNumbers message=($smsMessages->"normal")]
  }
}
