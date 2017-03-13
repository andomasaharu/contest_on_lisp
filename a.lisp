(defmacro range(n) `(loop for i from 0 to ,n collect i))
(format t "~A~%" (range 10))

(defmacro fm (a) `(format t "~A~%" ,a))
(fm (range 10))

(defmacro toint(s) `(parse-integer ,s))
(fm (toint "123"))

(defmacro foldl (fn lst initval) `(reduce ,fn ,lst :initial-value ,initval))
(fm (foldl #'+ '(1 2 3 4 5) 0))

(defmacro foldl1 (fn lst) `(reduce ,fn ,lst))
(fm (foldl1 #'+ '(1 2 3 4 5)))

(defun list-to-vector(lst)
  (coerce lst 'vector))

(defun my-parse-integer-rec(s)
  (labels ((rec (s r)
                (if (string= s "")
                  (nreverse r)
                  (multiple-value-bind (a b)
                    (parse-integer s :junk-allowed t)
                    (rec (subseq s b) (cons a r))))))
    (rec s nil)))
(compile 'my-parse-integer-rec)
(format t "~A~%" (my-parse-integer-rec "123 456"))

(defmacro aif(pred thenform elseform)
  `(let ((it ,pred))
     (if it
       ,thenform
       ,elseform)))
(aif (cdr '(1 2 3))
(fm (car it))
(fm "null cdr~%"))

(defmacro dbgfmt(&body body)
  `(format t ,(format nil "~{~A~}~~%" (mapcar (lambda(a) (format nil "~(~A:~~A ~)" a)) body)) ,@body))
  (let ((a 1)
  (b '(a b c))
  (c 1000))
  (dbgfmt a b c))
  
(defmacro compiles(&body body)
  `(progn
    ,@(mapcar (lambda(a) `(compile ',a)) body)))
;(compiles 'myfunctionname1 'myfunctionname2)    

(defun flatten1(lst)
  (nreverse (reduce (lambda (acc a)
					  (reduce (lambda (acc a)
								(cons a acc))
							  a :initial-value acc))
					lst :initial-value nil)))

(defun permutations(lst)
  (labels ((skip(i n lst acc)
			 (cond ((null lst) acc)
				   ((= i n) (skip (1+ i) n (cdr lst) acc))
				   (t (skip (1+ i) n (cdr lst) (cons (car lst) acc)))))
		   (rec (lst acc acc0)
				(if (null lst)
				  (cons acc acc0)
				  (flatten1 (mapcar (lambda(i) (rec (nreverse (skip 0 i lst nil)) (cons (nth i lst) acc) acc0)) (loop for i from 0 to (1- (length lst)) collect i)))
				  ))
				)
	(rec lst nil nil)))

(defun subsequences(nums fn)
	(labels ((rec (acc lst)
				  (unless (null lst)
					(let ((a (car lst)))
					  (when (funcall fn (cons a acc))
						(rec acc (cdr lst))
						(rec (cons a acc) (cdr lst)))))))
	  (rec nil nums)))

(defun splitat (c line)
  (labels ((rec (line acc)
				(let ((pos (position-if (lambda(cc) (char= c cc)) line)))
				  (if pos
					  (rec (subseq line (1+ pos)) (cons (subseq line 0 pos) acc))
					(cons line acc)))))
	(rec line nil)))
	;(splitat #\a "john mccarthy")
(defun readline (callback)
  (labels ((rec (i)
				(let ((line (read-line nil nil)))
				  (when (not (zerop (length line)))
					(funcall callback line i)
					(rec (1+ i))))))
	(rec 0)))
	;(readline (lambda(line i)))
(defun start()
  (let ((limit 0)
        (lst nil))
    (readline (lambda(line i)
                (cond ((zerop i) (setf limit (read-from-string line)))
                      ((= limit i) (format t "~A~%" (compute (cons (read-from-string line) lst))))
                      (t (setf lst (cons (read-from-string line) lst))))))))
(start)
