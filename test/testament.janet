# (import ../src/testament :prefix "" :exit true)
(import ../src/testament :as t :exit true)


(defn test-deftest-macro []
  (t/deftest test-name :noop)
  (unless (= :function (type test-name))
    (error "Test failed")))


(test-deftest-macro)


(defn test-assert-expr-macro []
  (let [summary (t/assert-expr 1)]
    (unless (= {:passed? true :note "1" :details "Passed"} summary)
      (error "Test failed"))))


(test-assert-expr-macro)


(defn test-assert-equal-macro []
  (let [summary (t/assert-equal 1 1)]
    (unless (= {:passed? true :note "(= 1 1)" :details "Passed"} summary)
      (error "Test failed"))))


(test-assert-equal-macro)


(defn test-assert-thrown-macro []
  (let [summary (t/assert-thrown (error "An error"))]
    (unless (= {:passed? true :note "thrown? (error \"An error\")" :details "Passed"} summary)
      (error "Test failed"))))


(test-assert-thrown-macro)


(defn test-assert-thrown-message-macro []
  (let [summary (t/assert-thrown-message "An error" (error "An error"))]
    (unless (= {:passed? true :note "thrown? \"An error\" (error \"An error\")" :details "Passed"} summary)
      (error "Test failed"))))


(test-assert-thrown-message-macro)


(defn test-is-macro-with-value []
  (let (summary (t/is 1))
    (unless (= {:passed? true :note "1" :details "Passed"} summary)
      (error "Test failed"))))


(test-is-macro-with-value)


(defn test-is-macro-with-equality []
  (let (summary (t/is (= 1 2)))
    (unless (= {:passed? false :note "(= 1 2)" :details "Expect: 1\nActual: 2"} summary)
      (error "Test failed"))))


(test-is-macro-with-equality)


(defn test-is-macro-with-thrown []
  (let [summary (t/is (thrown? (error "An error")))]
    (unless (= {:passed? true :note "thrown? (error \"An error\")" :details "Passed"} summary)
      (error "Test failed"))))


(test-is-macro-with-thrown)


(defn test-is-macro-with-thrown-message []
  (let [summary (t/is (thrown? "An error" (error "An error")))]
    (unless (= {:passed? true :note "thrown? \"An error\" (error \"An error\")" :details "Passed"} summary)
      (error "Test failed"))))


(test-is-macro-with-thrown-message)


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

(defn test-custom-reporting []
  (t/set-report-printer (fn [notests noasserts nopassed]
                          (print "CUSTOM:" notests ":" noasserts ":" nopassed ":")))
  (t/deftest test-name (t/assert-equal 1 1))
  (let [output @""]
    (with-dyns [:out output]
      (t/run-tests!))
    (unless (= (string "CUSTOM:1:1:1:" "\n") (string output))
      (error "Test failed"))))


(test-custom-reporting)


(t/reset-tests!)

(defn test-on-result-hook []
  (var called false)
  (t/set-on-result-hook (fn [summary]
                          (unless (= {:passed? true :note "1" :details "Passed"} summary)
                            (error "Test failed"))
                          (set called true)))
  (t/deftest test-name (t/assert-equal 1 1 "1"))
  (let [output @""]
    (with-dyns [:out output]
      (t/run-tests!))
    (unless called
      (error "Test failed. on-result-hook was not called."))))


(test-on-result-hook)


(t/reset-tests!)

(defn test-reporting-silent []
  (t/deftest test-name (t/assert-equal 1 1))
  (let [output @""]
    (with-dyns [:out output]
      (t/run-tests! :silent true))
    (unless (empty? (string output))
      (error "Test failed"))))


(test-reporting-silent)
