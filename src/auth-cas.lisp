(defpackage lack.middleware.auth.cas
  (:use :cl :cl-cas :alexandria)
  (:export :*lack-middleware-auth-cas*))

(in-package :lack.middleware.auth.cas)

(defun ajax-request-p (env)
  (let ((headers (getf env :headers)))
    (when-let ((request-origin (gethash "x-requested-with" headers)))
     (string-equal request-origin "xmlhttprequest"))))

(defun user-uid (env)
  (when-let ((session (getf env :lack.session)))
    (gethash :user-uid session nil)))

(defun request-url (env)
  (format nil "~a://~a:~a~a"
          (getf env :url-scheme)
          (getf env :server-name)
          (getf env :server-port)
          (getf env :path-info)))

(defun authenticatedp (env)
  "May return two values : status and renew-flag"
  (let ((renew-flag ()))
    (values (user-uid env) renew-flag)))

(defun session-store-cas-user-uid (env uid)
  (setf (gethash :user-uid (getf env :lack.session) nil) uid))


(defparameter *lack-middleware-auth-cas*
  (lambda (app &key cas-url (authenticatedp 'authenticatedp))
    (lambda (env)
      (block nil
        (multiple-value-bind (status renew-flag)
            (funcall authenticatedp env)
          (if status
              (funcall app env)
              (let ((url (request-url env))
                    (qs (getf env :query-string)))
                (if-let ((ticket (and qs (cas:cas-ticket qs))))
                  (if-let ((uid (cas:cas-validate cas-url url ticket :renew renew-flag)))
                    (progn
                      (session-store-cas-user-uid env uid)
                      (funcall app env))
                    (return-500))
                  (if (ajax-request-p env)
                      (return-401)
                      (return-302 (cas:cas-login cas-url url))))))))))
  "Middleware for CAS Authentication")

(defun return-500 ()
  `(500
    (:content-type "text/plain"
     :content-length 52)
    ("Internal Server Error : Cas ticket validation failed")))

(defun return-302 (url)
  `(302 (:Location ,url)))

(defun return-401 ()
  `(401 (:content-type "text/plain"
         :content-length 12)
        ("Unauthorized")))

