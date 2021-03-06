;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Sample Scheme program that computes the Nth prime number ;;
;; using sieve built from chaining filtering tasks          ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(load "samples/mailboxes.scm")

;;;;;;;;;;;;;;;;;;;;;;;;
;; Processing threads ;;
;;;;;;;;;;;;;;;;;;;;;;;;
(define (filter-composites prime mailbox child-mailbox)
  (let ((next-number (mailbox-receive mailbox)))
    (if (= (remainder next-number prime) 0)
        (filter-composites prime mailbox child-mailbox)
        (begin (mailbox-send child-mailbox next-number)
               (filter-composites prime mailbox child-mailbox)))))
(define (filter-task mailbox primes-mailbox)
  (make-task (lambda ()
               (let ((prime (mailbox-receive mailbox)))
                 (begin (mailbox-send primes-mailbox prime)
                        (let ((child-mailbox (make-mailbox)))
                          (let ((child (filter-task child-mailbox
                                                    primes-mailbox)))
                            (filter-composites prime mailbox
                                               child-mailbox))))))))
(define (drive next-number mailbox)
  (begin (mailbox-send mailbox next-number)
         (drive (+ next-number 1) mailbox)))
(define (driver-task mailbox)
  (make-task (lambda () (drive 2 mailbox))))
(define (read-primes count primes-mailbox)
  (if (> count 0)
      (cons (mailbox-receive primes-mailbox)
            (read-primes (- count 1) primes-mailbox))
      '()))
(let ((numbers-mailbox (make-mailbox))
      (primes-mailbox (make-mailbox)))
  (let ((filter (filter-task numbers-mailbox primes-mailbox))
        (driver (driver-task numbers-mailbox)))
    (begin (display (read-primes 100 primes-mailbox))
           (newline)
           (task-kill filter)
           (task-kill driver))))
