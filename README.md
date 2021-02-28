# cl-lmac

Lack Middleware Authentication CAS 

cl-lmac is a CAS authentication middleware for [Caveman2][CAV] ([Lack][LACK]).

cl-lmac depends on [cl-cas][CAS]

## Platform
Only tested under GNU/LINUX with [SBCL][SBCL] and [Quicklisp][QL]

## How it works

You need a functional CAS Server (see https://github.com/apereo/cas).

* Add CAS Server url to your app : add *cas-url* parameter to config file (config.lisp)
```lisp
(defparameter *cas-url* "https://<cas server>/cas")
```
* Add Middleware to your Caveman2 application : add middleware to builder (app.lisp)
  * (list :auth-cas :cas-url *cas-url*) 
* [Optional] Define your own authenticatedp function
* When the user is authenticated, the user id (uid) is stored in the user session
  * Get the uid : (gethash :user-uid *session*)

Warning : This middleware only authenticate users, you have to write your own authorization code.

[LACK]: https://github.com/fukamachi/lack "Lack"
[CAS]: https://github.com/flotsfacetieux/cl-cas "cl-cas" 
[SBCL]: http://www.sbcl.org/platform-table.html "SBCL"
[QL]: https://www.quicklisp.org/beta/ "Quicklisp"
[CAV]: https://github.com/fukamachi/caveman/ "Caveman2"