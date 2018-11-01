# "$username:$password" base64 encoded
:global TeliaAPIConfig
:if (!any $TeliaAPIConfig) do={
  :global TeliaAPIConfig {
    "baseurl"="https://bendik.konstant.no/telia-api"
    "auth"="dXNlcm5hbWU6cGFzc3dvcmQ="
  }
}

:global arrayToString
:if (!any $arrayToString) do={ :global arrayToString do={
  :local str ""
  :local delimiter ","
  :if (any $delim) do={ :set delimiter $delim }
  :local arr $1

  :foreach k,v in=$arr do={
    :if ([:typeof $k] = "str") do={
      :set v ($k . "=" . $v)
    }
    :set str ($str . $delimiter . $v)
  }
  :if ([:len $str] > 0) do={
    :set str [:pick $str 1 [:len $str]]
  }
  :return $str
}}

:global toQueryString
:if (!any $toQueryString) do={ :global toQueryString do={
  :global arrayToString
  :return [$arrayToString delim="&" $1]
}}

:global TeliaAPIRequest
:if (!any $TeliaAPIRequest) do={ :global TeliaAPIRequest do={
  :global TeliaAPIConfig
  :local httpmethod "get"
  :local requestquery ""
  :local httpdata ""
  :if (any $method) do={ :set httpmethod $method }
  :if (any $query) do={ :set requestquery $query }
  :if (any $data) do={ :set httpdata $data }

  :if ([:typeof $requestquery] = "array") do={
    :global toQueryString
    :set requestquery [$toQueryString $requestquery]
  }

  :local requesturl ($TeliaAPIConfig->"baseurl" . "/" . $1 . "?" . $requestquery . "&auth=" . $TeliaAPIConfig->"auth")
  :log info "TeliaAPI -- Doing $method http-request using URL $requesturl"
  :if ($method = "post") do={ :log info "TeliaAPI -- POST: $httpdata" }
  :local httpresponse [/tool fetch url=$requesturl http-method=$httpmethod http-data=$httpdata dst-path="TeliaAPIRequest" as-value output=user]
  :if ($httpresponse->"status" = "finished") do={
    :return ($httpresponse->"data")
  } else={
    :log warning "TeliaAPI -- Got falsy httpresponse: $httpresponse"
    :return false
  }
}}

:global TeliaAPISendSMS
:if (!any $TeliaAPISendSMS) do={ :global TeliaAPISendSMS do={
  :global TeliaAPIConfig
  :global TeliaAPIRequest

  :local contacts ""
  :local msg ""
  :local dosave "false"
  :if (any $message) do={ :set msg $message } else={ :set msg $1 }
  :if (any $save) do={ :set dosave "true" }
  :if ([:typeof $numbers] = "array") do={
    :global arrayToString
    :set contacts [$arrayToString $numbers]
  } else={
    :set contacts $numbers
  }
  :log info "TeliaAPISendSMS -- Sending message $1 to $contacts"
  :local sms ("{\"Message\":\"" . [:tostr $msg] . "\",\"Contacts\":[" . $contacts . "],\"Save\":" . $dosave . "}")
  :local ret [$TeliaAPIRequest method="post" data=$sms "messaging/sms/send"]
  :return $ret
}}

:global TeliaAPIUnload
:if (!any $TeliaAPIUnload) do={ :global TeliaAPIUnload do={
  :global TeliaAPIConfig; :set TeliaAPIConfig
  :global TeliaAPIRequest; :set TeliaAPIRequest
  :global toQueryString; :set toQueryString
  :global arrayToString; :set arrayToString
  :global TeliaAPISendSMS; :set TeliaAPISendSMS
  :global TeliaAPIUnload; :set TeliaAPIUnload
}}

#
# Usage
#

#:system script run "TeliaAPI"
#:global TeliaAPIRequest
#:global TeliaAPISendSMS
#:local usageinfo [$TeliaAPIRequest "usageinfo" "msisdn=47580009042486&nocache=true"]
#:log info "-- TeliaAPIRequest response: $usageinfo"
#[$TeliaAPISendSMS numbers="4799999999" message="Hello hello!" save=true]
