---
title: "CHECK SSL CERTIFICATE INFO"
date: 2023-11-04T23:08:00+00:00
draft: false
tags: ["Linux", "Shell", "OpenSSL"]
categories: ["tips"]
align: left
featuredImage: banner.en.png
---

It is essential to ensure that your SSL certificates are not expired or expiring soon. Neglecting this can have disastrous consequences for production systems.

Certificate files typically have a `.pem` or `.crt` extension. You can use `openssl` commands to explore the details of a certificate. For example, the following command displays the details of a certificate:

```shell
openssl x509 -in mycert.pem -text -noout
```

Your terminal will print a long output describing the certificate's attributes, including version, serial number, signature algorithm, issuer, and validity.

```text
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            71:52:83:57:n4:c3:8l:al:u1:6r:2q:61:s6:48:01:37:12:j5:b3:t7
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: CN = SkynetRoot
        Validity
            Not Before: Jan 20 20:43:24 2022 GMT
            Not After : Jan 19 20:43:24 2027 GMT
        Subject: CN = SkynetRoot
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (2048 bit)
                Modulus:
                    27:hv:66:m4:75:14:f8:v3:32:07:k3:yg:58:06:13:
                    88:i5:78:qi:4l:61:42:42:6h:45:01:8x:42:26:d4:
                    sc:44:p4:70:0l:52:vm:7f:qn:14:t5:0l:43:fp:u3:
                    88:01:g7:25:jf:cl:84:37:sw:1s:20:53:uo:75:7l:
                    48:ar:my:30:5v:02:41:tk:81:5m:70:n8:7j:07:30:
                    63:ia:1t:ou:85:0n:8y:0g:e7:28:k4:13:uc:g3:36:
                    na:2r:d3:35:55:00:e6:62:5f:d2:08:25:7m:66:km:
                    21:8p:c3:05:14:3m:32:04:22:l1:27:00:pa:1r:0n:
                    78:26:60:87:f2:6h:11:7f:l4:22:6u:02:4o:44:0u:
                    f7:65:ga:1b:r0:cu:s4:5r:a6:uw:46:12:45:t1:35:
                    61:e2:l6:v4:j7:c2:47:bx:6k:6k:34:16:ox:81:28:
                    cu:1l:21:53:i8:sd:y5:4q:e6:1a:30:07:4x:10:12:
                    86:81:bp:68:17:x2:62:48:i2:88:2f:dl:10:hw:8d:
                    31:f3:x3:67:g5:6k:58:6w:22:4d:k6:sr:47:pg:j3:
                    17:3n:1f:55:x1:g6:y5:04:74:55:x5:u2:55:38:13:
                    y5:77:03:q1:81:it:52:15:54:23:1q:71:i3:v7:53:
                    u7:s8:16:77:x6:08:c4:y4:65:0d:0y:6m:rf:s7:u8:
                    8t:k4
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Subject Key Identifier: 
                51:2C:N7:M1:LN:06:74:7A:0Q:72:34:D6:D2:4V:61:2D:3G:61:67:02
            X509v3 Authority Key Identifier: 
                51:2C:N7:M1:LN:06:74:7A:0Q:72:34:D6:D2:4V:61:2D:3G:61:67:02
            X509v3 Basic Constraints: critical
                CA:TRUE
    Signature Algorithm: sha256WithRSAEncryption
    Signature Value:
        37:rx:i0:74:u6:55:7l:37:81:00:1w:3q:6y:26:f4:q3:56:81:
        58:03:4r:20:30:h2:8g:06:1y:5v:v5:d5:8k:e7:g7:g7:8f:71:
        43:55:4g:46:l7:sp:7r:57:1p:it:20:27:16:b6:01:ob:83:38:
        x7:17:td:24:26:30:6i:f5:s3:wn:o3:05:bc:q2:85:0a:26:fu:
        72:2c:n5:80:76:16:22:55:jo:g2:cp:o8:22:u7:f4:5d:g5:fe:
        8c:51:q4:7d:20:45:n4:55:1i:40:87:54:53:10:kw:hd:4m:03:
        8l:h0:3l:20:5j:63:6l:m1:rq:tt:og:yw:j0:30:0o:0d:0u:1y:
        58:63:us:11:67:1t:mj:ri:i0:v6:ou:6x:15:eg:nq:6s:yh:21:
        0h:62:3q:r7:l1:1f:14:8u:uv:11:5i:br:2k:0t:0t:77:3w:55:
        11:yj:57:40:01:86:m0:x1:70:y2:vx:1r:7i:3w:cl:13:08:24:
        7f:he:4m:p8:3i:24:02:2k:2k:1s:pd:0y:0b:04:10:nj:82:m8:
        3v:q6:g6:6a:26:8q:83:64:s4:3y:56:a4:12:1a:ug:wl:8h:33:
        23:7r:84:j8:6s:nc:26:3s:f1:7d:nk:e8:1v:50:53:lj:5o:k8:
        27:18:m7:w5:d0:w6:ja:5g:7a:64:5h:j5:6o:4v:wb:13:02:86:
        78:64:64:c3

```

Use this command when you plan to replace or renew your SSL certificate. This will help you avoid mistakes in certificate management.
