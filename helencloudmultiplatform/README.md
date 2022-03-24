# helencloudmultiplatform

helen Cloud Integration Multiplatform

## Getting Started

This project is a starting point to implement helen Cloud SaaS in any backend.

SaaS access method:
  HTTP POST method
  
POST Method parameters:
  Headers: "Accept: application/json"
  Body: {'sentence':<TEXT2CONVERT>, 'language':<SIGNLANGUAGE>}
  
Currently Supported Sign Lnaguages:
  lesco
  
Response type:
  <STRING> -> If successful returns video URL | Else returns error message
    
For production please contact @ hello@helenai.com
*Demo does not support user validation
