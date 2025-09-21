(import ../lib/testament :as t :exit true)


(defn test-== []
  (def x [@[{:a 1}]])
  (def y @[[@{:a 1}]])
  (unless (t/== x y)
    (error "Test failed")))

(test-==)


(defn test-deftest-macro []
  (t/deftest test-name :noop)
  (unless (= :function (type test-name))
    (error "Test failed")))

(test-deftest-macro)


(defn test-deftest-same-name-macro []
  (t/deftest same-name :noop)
  (def err @"")
  (with-dyns [:err err]
    (t/deftest same-name :noop)
    (unless (= (string err) "[testament] registered multiple tests with the same name\n")
      (error "no warning"))))

(test-deftest-same-name-macro)


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


(defn test-assert-deep-equal-macro []
  (let [summary (t/assert-deep-equal @[1] @[1])]
    (unless (deep= summary {:kind    :equal
                            :passed? true
                            :expect  @[1]
                            :actual  @[1]
                            :note    "(deep= @[1] @[1])"})
      (error "Test failed"))))

(test-assert-deep-equal-macro)


(defn test-assert-equivalent-macro []
  (let [summary (t/assert-equivalent [1] @[1])]
    (unless (deep= summary {:kind    :equal
                            :passed? true
                            :expect  [1]
                            :actual  @[1]
                            :note    "(== [1] @[1])"})
      (error "Test failed"))))

(test-assert-equivalent-macro)


(defn test-assert-matches-macro []
  (let [summary (t/assert-matches {:a _} {:a 10})]
    (unless (deep= summary {:kind    :matches
                            :passed? true
                            :expect  {:a '_}
                            :actual  {:a 10}
                            :note    "(matches {:a _} {:a 10})"})
     (error "Test failed"))))

(test-assert-matches-macro)


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


(defn test-is-macro-with-deep-equality []
  (let [summary (t/is (deep= @[1] @[2]))]
    (unless (deep= summary {:kind    :equal
                            :passed? false
                            :expect  @[1]
                            :actual  @[2]
                            :note    "(deep= @[1] @[2])"})
      (error "Test failed"))))

(test-is-macro-with-deep-equality)


(defn test-is-macro-with-equivalence []
  (let [summary (t/is (== [1] @[2]))]
    (unless (deep= summary {:kind    :equal
                            :passed? false
                            :expect  [1]
                            :actual  @[2]
                            :note    "(== [1] @[2])"})
      (error "Test failed"))))

(test-is-macro-with-equivalence)


(defn test-is-macro-with-matches []
  (let [summary (t/is (matches {:b _} {:a 10}))]
    (unless (deep= summary {:kind    :matches
                            :passed? false
                            :expect  {:b '_}
                            :actual  {:a 10}
                            :note    "(matches {:b _} {:a 10})"})
     (error "Test failed"))))

(test-is-macro-with-matches)


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


(t/reset-all!)

(defn test-exit-code-success []
  (t/deftest test-name (t/assert-equal 1 1))
  (let [expect @[@{:test     'test-name
                   :failures @[]
                   :passes   @[{:test    'test-name
                                :kind    :equal
                                :passed? true
                                :expect  1
                                :actual  1
                                :note    "(= 1 1)"}]}]
        actual (t/run-tests! :silent true)]
    (unless (deep= expect actual)
      (error "Test failed"))))

(test-exit-code-success)


(t/reset-all!)

(defn test-exit-code-failure []
  (t/deftest test-name (t/assert-equal 1 2))
  (let [expect @[@{:test     'test-name
                   :passes   @[]
                   :failures @[{:test    'test-name
                                :kind    :equal
                                :passed? false
                                :expect  1
                                :actual  2
                                :note    "(= 1 2)"}]}]
        actual (t/run-tests! :silent true :exit-on-fail false)]
    (unless (deep= expect actual)
      (error "Test failed"))))

(test-exit-code-failure)


(t/reset-all!)

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


(t/reset-all!)

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


(t/reset-all!)

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


(t/reset-all!)

(defn test-reporting-silent []
  (t/deftest test-name (t/assert-equal 1 1))
  (let [output @""]
    (with-dyns [:out output]
      (t/run-tests! :silent true))
    (unless (empty? (string output))
      (error "Test failed"))))

(test-reporting-silent)


(t/reset-all!)

(defn test-exercise! []
  (let [output @""
        stats  "1 tests run containing 1 assertions\n1 tests passed, 0 tests failed"
        len    (->> (string/split "\n" stats) (map length) splice max)
        rule   (string/repeat "-" len)]
    (with-dyns [:out output]
      (t/exercise! []
        (t/deftest test-name (t/assert-equal 1 1))))
    (unless (= (string "\n" rule "\n" stats "\n" rule "\n") (string output))
      (error "Test failed"))))

(test-exercise!)


(t/reset-all!)

(defn test-exercise!-silent []
  (let [output @""]
    (with-dyns [:out output]
      (t/exercise! [:silent true]
        (t/deftest test-name (t/assert-equal 1 1))))
    (unless (empty? (string output))
      (error "Test failed"))))

(test-exercise!-silent)


(t/reset-all!)

(defn test-call-test []
  (t/deftest testname (t/assert-equal 1 2))
  (let [output @""]
    (with-dyns [:out output]
      (testname))
    (def expect
      ```
      > Failed: testname
      Assertion: (= 1 2)
      Expect (L): 1
      Actual (R): 2
      ```)
    (unless (= (string expect "\n") (string output))
      (error "Test failed"))))

(test-call-test)


(t/reset-all!)

(defn test-call-tests []
  (setdyn :tests ['test-name1])
  (t/deftest test-name1 (t/assert-equal 1 1))
  (t/deftest test-name2 (t/assert-equal 1 1))
  (let [expect @[@{:test     'test-name1
                   :failures @[]
                   :passes   @[{:test    'test-name1
                                :kind    :equal
                                :passed? true
                                :expect  1
                                :actual  1
                                :note    "(= 1 1)"}]}]
        actual (t/run-tests! :silent true)]
    (unless (deep= expect actual)
      (error "Test failed"))))

(test-call-tests)


(t/reset-all!)

(defn test-skip-tests []
  (setdyn :skips ['test-name2])
  (t/deftest test-name1 (t/assert-equal 1 1))
  (t/deftest test-name2 (t/assert-equal 1 1))
  (let [expect @[@{:test     'test-name1
                   :failures @[]
                   :passes   @[{:test    'test-name1
                                :kind    :equal
                                :passed? true
                                :expect  1
                                :actual  1
                                :note    "(= 1 1)"}]}]
        actual (t/run-tests! :silent true)]
    (unless (deep= expect actual)
      (error "Test failed"))))

(test-skip-tests)
