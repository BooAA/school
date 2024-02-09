;;;; test.lisp ;;;;

;;; (test 'run) feeds every hack assemble program to assembler
;;; (test 'clean) remove all the generated machine code

(defun test (option)
  (cond ((eq option 'run)
         (ignore-errors (load "assembler.lisp")
                        (assembler "../add/Add.asm")
                        (assembler "../max/Max.asm")
                        (assembler "../max/MaxL.asm")
                        (assembler "../rect/Rect.asm")
                        (assembler "../rect/RectL.asm")
                        (assembler "../pong/Pong.asm")
                        (assembler "../pong/PongL.asm")))
        ((eq option 'clean)
         (ignore-errors (delete-file "../add/Add.hack")
                        (delete-file "../max/Max.hack")
                        (delete-file "../max/MaxL.hack")
                        (delete-file "../rect/Rect.hack")
                        (delete-file "../rect/RectL.hack")
                        (delete-file "../pong/Pong.hack")
                        (delete-file "../pong/PongL.hack")))))


