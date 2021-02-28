(defsystem "cl-lmac" 
  :version "0.1"
  :author "Frederic FERRERE"
  :license "LLGPL"
  :description "Lack MiddleWare Authentication CAS package"
  :depends-on (:alexandria :cl-cas :split-sequence :quri)
  :components ((:module "src"
                :components
                ((:file "auth-cas")))))
