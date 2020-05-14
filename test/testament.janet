# (import ../src/testament :prefix "" :exit true)
(import ../src/testament :as t :exit true)


(defn test-deftest-macro []
  (t/deftest test-name :noop)
  (unless (= :function (type test-name))
    (error "Test failed")))


(test-deftest-macro)


(defn test-assert-expr-macro []
  (let [summary (t/assert-expr 1)]
    (unless (= {:passed? true :note "1" :report "Passed"} summary)
      (error "Test failed"))))


(test-assert-expr-macro)


(defn test-assert-equal-macro []
  (let [summary (t/assert-equal 1 1)]
    (unless (= {:passed? true :note "(= 1 1)" :report "Passed"} summary)
      (error "Test failed"))))


(test-assert-equal-macro)


(defn test-assert-thrown-macro []
  (let [summary (t/assert-thrown (error "An error"))]
    (unless (= {:passed? true :note "thrown? (error \"An error\")" :report "Passed"} summary)
      (error "Test failed"))))


(test-assert-thrown-macro)


(defn test-is-macro-with-value []
  (let (summary (t/is 1))
    (unless (= {:passed? true :note "1" :report "Passed"} summary)
      (error "Test failed"))))


(test-is-macro-with-value)


(defn test-is-macro-with-equality []
  (let (summary (t/is (= 1 2)))
    (unless (= {:passed? false :note "(= 1 2)" :report "Expected: 1\nActual: 2"} summary)
      (error "Test failed"))))


(test-is-macro-with-equality)


(defn test-is-macro-with-thrown []
  (let [summary (t/is (thrown? (error "An error")))]
    (unless (= {:passed? true :note "thrown? (error \"An error\")" :report "Passed"} summary)
      (error "Test failed"))))


(test-is-macro-with-thrown)


(t/reset-tests!)

(defn test-reporting []
  (t/deftest test-name (t/assert-equal 1 1))
  (let [output @""
        stats  "1 tests run containing 1 assertions\n1 tests passed, 0 tests failed"
        len    (->> (string/split "\n" stats) (map length) splice max)
        rule   (string/repeat "-" len)]
    (with-dyns [:out output]
      (t/run-tests!))
    (unless (= (string "\n" rule "\n" stats "\n" rule "\n") (string output))
      (error "Test failed"))))


(test-reporting)


(t/reset-tests!)

(defn test-reporting-silent []
  (t/deftest test-name (t/assert-equal 1 1))
  (let [output @""]
    (with-dyns [:out output]
      (t/run-tests! :silent true))
    (unless (empty? (string output))
      (error "Test failed"))))


(test-reporting-silent)
