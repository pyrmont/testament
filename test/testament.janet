(import ../src/testament :prefix "" :exit true)


(defn test-deftest-macro []
  (deftest test-name :noop)
  (unless (= :function (type test-name))
    (error "Test failed")))


(test-deftest-macro)


(defn test-assert-equal-macro []
  (let [summary (assert-equal 1 1)]
    (unless (= {:passed? true :note "1" :report "Passed"} summary)
      (error "Test failed"))))


(test-assert-equal-macro)


(reset-tests!)

(defn test-reporting []
  (deftest test-name (assert-equal 1 1))
  (let [output @""
        stats  "1 tests run, 1 tests passed, 0 tests failed"
        rule   (string/repeat "-" (length stats))]
    (with-dyns [:out output]
      (run-tests!))
    (unless (= (string "\n" rule "\n" stats "\n" rule "\n") (string output))
      (error "Test failed"))))


(test-reporting)
