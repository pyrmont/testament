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


(defn test-assert-expr-macro []
  (let [summary (assert-expr 1)]
    (unless (= {:passed? true :note "1" :report "Passed"} summary)
      (error "Test failed"))))


(test-assert-expr-macro)


(defn test-is-macro-with-value []
  (let (summary (is 1))
    (unless (= {:passed? true :note "1" :report "Passed"} summary)
      (error "Test failed"))))


(test-is-macro-with-value)


(defn test-is-macro-with-equality []
  (let (summary (is (= 1 2)))
    (unless (= {:passed? false :note "2" :report "Expected: 1\nActual: 2"} summary)
      (error "Test failed"))))


(test-is-macro-with-equality)


(reset-tests!)

(defn test-reporting []
  (deftest test-name (assert-equal 1 1))
  (let [output @""
        stats  "1 tests run containing 1 assertions\n1 tests passed, 0 tests failed"
        len    (->> (string/split "\n" stats) (map length) splice max)
        rule   (string/repeat "-" len)]
    (with-dyns [:out output]
      (run-tests!))
    (unless (= (string "\n" rule "\n" stats "\n" rule "\n") (string output))
      (error "Test failed"))))


(test-reporting)
