#!/bin/bash
function run_test() {
    echo 'Testing the sample code for the publisher-subscriber pattern'
    ./multischemec.sh -o bin/test <(echo '
(load "samples/with-subscriber.scm")

(define (display-messages mailbox)
  (begin (display (mailbox-receive mailbox))
         (newline)
         (display-messages mailbox)))
(define (mailbox-sends mailbox)
  (define (send-sequence start end)
     (if (< start end)
         (begin (mailbox-send mailbox start)
                (send-sequence (+ start 1) end))))
  (send-sequence 0 10))
(with-subscriber display-messages mailbox-sends)')
    OUTPUT=`bin/test`
    EXPECTED="0
1
2
3
4
5
6
7
8
9"
    if [ "$OUTPUT" = "$EXPECTED" ]; then
        echo $'\tPassed'
        return 0
    else
        echo $'\tFailed'
        return 1
    fi
}
run_test