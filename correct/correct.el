(require 'cl)
(defun memo-table (n m)
  (let ((memo (make-vector n nil)))
    (dotimes (i n)
      (aset memo i (make-vector m nil)))
    memo))

(defun levenshtein (s1 s2)
  (let ((memo (memo-table (length s1) (length s2))))
    (flet ((lev (i j)
                (let ((stored (aref (aref memo i) j)))
                  (if stored
                      stored
                    (let ((res (if (= (min i j) 0)
                                   (max i j)
                                 (min (+ 1 (lev (- i 1) j))
                                      (+ 1 (lev i (- j 1)))
                                      (+ (lev (- i 1) (- j 1))
                                         (if (= (aref s1 i) (aref s2 j))
                                             0
                                           1))))))
                      (aset (aref memo i) j res)
                      res)))))
          (lev (- (length s1) 1) (- (length s2) 1)))))

(levenshtein "scattergory" "category")

