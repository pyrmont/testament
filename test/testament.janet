# (import ../src/testament :prefix "" :exit true)
(import ../src/testament :as t :exit true)


(defn test-== []
  (def x [1])
  (def y @[1])
  (unless (t/== x y)
    (error "Test failed")))


(test-==)


(defn test-deftest-macro []
  (t/deftest test-name :noop)
  (unless (= :function (type test-name))
    (error "Test failed")))


(test-deftest-macro)


(defn test-anon-deftest-macro []
  (def anon-test (t/deftest :noop))
  (unless (= :function (type anon-test))
    (error "Test failed")))


(test-anon-deftest-macro)


(defn test-assert-expr-macro []
  (let [summary (t/assert-expr 1)]
    (unless (= summary {:kind    :expr
                        :passed? true
                        :expect  true
                        :actual  true
                        :note    "1"})
      (error "Test failed"))))


(test-assert-expr-macro)


(defn test-assert-equal-macro []
  (let [summary (t/assert-equal 1 1)]
    (unless (= summary {:kind    :equal
                        :passed? true
                        :expect  1
                        :actual  1
                        :note    "(= 1 1)"})
      (error "Test failed"))))


(test-assert-equal-macro)


(defn test-assert-equivalent-macro []
  (let [summary (t/assert-equivalent [1] @[1])]
    (unless (deep= summary {:kind    :equal
                            :passed? true
                            :expect  [1]
                            :actual  @[1]
                            :note    "(== [1] @[1])"})
      (error "Test failed"))))


(test-assert-equivalent-macro)


(defn test-assert-thrown-macro []
  (let [summary (t/assert-thrown (error "An error"))]
    (unless (= summary {:kind    :thrown
                        :passed? true
                        :expect  true
                        :actual  true
                        :note    "thrown? (error \"An error\")"})
      (error "Test failed"))))


(test-assert-thrown-macro)


(defn test-assert-thrown-message-macro []
  (let [summary (t/assert-thrown-message "An error" (error "An error"))]
    (unless (= summary {:kind    :thrown-message
                        :passed? true
                        :expect  "An error"
                        :actual  "An error"
                        :note    "thrown? \"An error\" (error \"An error\")"})
      (error "Test failed"))))


(test-assert-thrown-message-macro)


(defn test-is-macro-with-value []
  (let [summary (t/is 1)]
    (unless (= summary {:kind    :expr
                        :passed? true
                        :expect  true
                        :actual  true
                        :note    "1"})
      (error "Test failed"))))


(test-is-macro-with-value)


(defn test-is-macro-with-equality []
  (let [summary (t/is (= 1 2))]
    (unless (= summary {:kind    :equal
                        :passed? false
                        :expect  1
                        :actual  2
                        :note    "(= 1 2)"})
      (error "Test failed"))))


(test-is-macro-with-equality)


(defn test-is-macro-with-equivalence []
  (let [summary (t/is (== [1] @[2]))]
    (unless (deep= summary {:kind    :equal
                            :passed? false
                            :expect  [1]
                            :actual  @[2]
                            :note    "(== [1] @[2])"})
      (error "Test failed"))))


(test-is-macro-with-equivalence)


(defn test-is-macro-with-thrown []
  (let [summary (t/is (thrown? (error "An error")))]
    (unless (= summary {:kind    :thrown
                        :passed? true
                        :expect  true
                        :actual  true
                        :note    "thrown? (error \"An error\")"})
      (error "Test failed"))))


(test-is-macro-with-thrown)


(defn test-is-macro-with-thrown-message []
  (let [summary (t/is (thrown? "An error" (error "An error")))]
    (unless (= summary {:kind    :thrown-message
                        :passed? true
                        :expect  "An error"
                        :actual  "An error"
                        :note    "thrown? \"An error\" (error \"An error\")"})
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
                          (unless (= summary {:test    'test-name
                                              :kind    :equal
                                              :passed? true
                                              :expect  1
                                              :actual  1
                                              :note   "1"})
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
