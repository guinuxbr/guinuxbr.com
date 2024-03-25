---
title: "POWERSHELL TEST NET CONNECTION"
date: 2024-03-25T10:46:55Z
draft: true
tags: ["Windows", "PowerShell", "Telnet"]
categories: ["tips"]
align: left
featuredImage: banner.en.png
---

[From Microsoft documentation](https://learn.microsoft.com/en-us/powershell/module/nettcpip/test-netconnection?view=windowsserver2022-ps): The `Test-NetConnection` `cmdlet` displays diagnostic information for a connection. It supports ping tests, TCP tests, route tracing, and route selection diagnostics. Depending on the input parameters, the output can include the DNS lookup results, a list of IP interfaces, IPsec rules, route/source address selection results, and/or confirmation of connection establishment.

To mimic the `Telnet` command one can use:

```powershell
Test-NetConnection -ComputerName <HOSTNAME OR IP> -InformationLevel "Detailed" -Port <DESTINATION PORT>
```

Test ping connectivity with detailed results

```powershell
Test-NetConnection -ComputerName <HOSTNAME OR IP> -InformationLevel "Detailed"
```
