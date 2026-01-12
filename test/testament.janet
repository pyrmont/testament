(import ../lib/testament :as t :exit true)

(setdyn :test/color? false)

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

(defn test-each-is-macro []
  (t/deftest test-name (t/each-is [(= 1 1) (= 1 2)]))
  (let [expect @[@{:test     'test-name
                   :passes   @[{:test    'test-name
                                :kind    :equal
                                :passed? true
                                :expect  1
                                :actual  1
                                :note    "(= 1 1)"}]
                   :failures @[{:test    'test-name
                                :kind    :equal
                                :passed? false
                                :expect  1
                                :actual  2
                                :note    "(= 1 2)"}]}]
        actual (t/run-tests! :silent? true :no-exit? true)]
    (unless (deep= expect actual)
      (error "Test failed"))))

(test-each-is-macro)


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
        actual (t/run-tests! :silent? true :no-exit? true)]
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
        actual (t/run-tests! :silent? true :no-exit? true)]
    (unless (deep= expect actual)
      (error "Test failed"))))

(test-exit-code-failure)


(t/reset-all!)

(defn test-reporting []
  (t/deftest test-name (t/assert-equal 1 1))
  (let [output @""
        stats  "1 tests run containing 1 assertions\n1 tests passed, 0 tests failed"
        len    (->> (string/split "\n" stats) (map length) splice max)
        rule   (string/repeat "=" len)]
    (with-dyns [:out output]
      (t/run-tests! :silent? false :no-exit? true))
    (unless (= (string rule "\n" stats "\n" rule "\n") (string output))
      (error "Test failed"))))

(test-reporting)


(t/reset-all!)

(defn test-custom-reporting []
  (t/set-report-printer (fn [notests noasserts nopassed]
                          (print "CUSTOM:" notests ":" noasserts ":" nopassed ":")))
  (t/deftest test-name (t/assert-equal 1 1))
  (let [output @""]
    (with-dyns [:out output]
      (t/run-tests! :silent? false :no-exit? true))
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
      (t/run-tests! :silent? false :no-exit? true))
    (unless called
      (error "Test failed. on-result-hook was not called."))))

(test-on-result-hook)


(t/reset-all!)

(defn test-reporting-silent []
  (t/deftest test-name (t/assert-equal 1 1))
  (let [output @""]
    (with-dyns [:out output]
      (t/run-tests! :silent? true :no-exit? true))
    (unless (empty? (string output))
      (error "Test failed"))))

(test-reporting-silent)


(t/reset-all!)

(defn test-exercise! []
  (let [output @""
        stats  "1 tests run containing 1 assertions\n1 tests passed, 0 tests failed"
        len    (->> (string/split "\n" stats) (map length) splice max)
        rule   (string/repeat "=" len)]
    (with-dyns [:out output]
      (t/exercise! [:silent? false :no-exit? true]
        (t/deftest test-name (t/assert-equal 1 1))))
    (unless (= (string rule "\n" stats "\n" rule "\n") (string output))
      (error "Test failed"))))

(test-exercise!)


(t/reset-all!)

(defn test-exercise!-silent []
  (let [output @""]
    (with-dyns [:out output]
      (t/exercise! [:silent? true :no-exit? true]
        (t/deftest test-name (t/assert-equal 1 1))))
    (unless (empty? (string output))
      (error "Test failed"))))

(test-exercise!-silent)


(t/reset-all!)

(defn test-call-test []
  (t/deftest testname (t/assert-equal 1 2))
  (let [output @""]
    (with-dyns [:out output :testament/diff? false]
      (testname))
    (def expect
      ```
      -----------------------------------
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
  (setdyn :test/tests ['test-name1])
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
        actual (t/run-tests! :silent? true :no-exit? true)]
    (unless (deep= expect actual)
      (error "Test failed"))))

(test-call-tests)


(t/reset-all!)

(defn test-skip-tests []
  (setdyn :test/skips ['test-name2])
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
        actual (t/run-tests! :silent? true :no-exit? true)]
    (unless (deep= expect actual)
      (error "Test failed"))))

(test-skip-tests)


(t/reset-all!)

# Test diff functionality

(defn test-diff-with-color []
  (t/deftest test-with-diff
    (t/assert-equal "hello" "hallo"))
  (let [output @""]
    (with-dyns [:out output :test/color? true]
      (test-with-diff))
    (def expect (string "-----------------------------------\n"
                        "> \e[31mFailed\e[0m: test-with-diff\n"
                        "Assertion: (= \"hello\" \"hallo\")\n"
                        "Expect (L): \"h\e[48;5;52me\e[0mllo\"\n"
                        "Actual (R): \"h\e[48;5;22ma\e[0mllo\"\n"))
    (unless (= expect (string output))
      (error "Test failed"))))

(test-diff-with-color)


(t/reset-all!)

(defn test-diff-without-color []
  (t/deftest test-no-color
    (t/assert-equal "hello" "hallo"))
  (let [output @""]
    (with-dyns [:out output :test/color? false]
      (test-no-color))
    (def expect (string "-----------------------------------\n"
                        "> Failed: test-no-color\n"
                        "Assertion: (= \"hello\" \"hallo\")\n"
                        "Expect (L): \"hello\"\n"
                        "Actual (R): \"hallo\"\n"))
    (unless (= expect (string output))
      (error "Test failed"))))

(test-diff-without-color)


(t/reset-all!)

(defn test-diff-long-string []
  (def long-str1 (string/repeat "x" 1001))
  (def long-str2 (string/repeat "y" 1001))
  (t/deftest test-long-diff
    (t/assert-equal long-str1 long-str2))
  (let [output @""]
    (with-dyns [:out output :test/color? true]
      (test-long-diff))
    (def expect
      (string "-----------------------------------\n"
              "> \e[31mFailed\e[0m: test-long-diff\n"
              "Assertion: (= long-str1 long-str2)\n"
              "Expect (L): \"\e[48;5;52m" long-str1 "\e[0m\"\n"
              "Actual (R): \"\e[48;5;22m" long-str2 "\e[0m\"\n"))
    (unless (= expect (string output))
      (error "Test failed"))))

(test-diff-long-string)


(t/reset-all!)

(defn test-diff-multi-char []
  (t/deftest test-multi-diff
    (t/assert-equal "The quick brown fox" "The quirk brawn fox"))
  (let [output @""]
    (with-dyns [:out output :test/color? true]
      (test-multi-diff))
    (def expect (string "-----------------------------------\n"
                        "> \e[31mFailed\e[0m: test-multi-diff\n"
                        "Assertion: (= \"The quick brown fox\" \"The quirk brawn fox\")\n"
                        "Expect (L): \"The qui\e[48;5;52mc\e[0mk br\e[48;5;52mo\e[0mwn fox\"\n"
                        "Actual (R): \"The qui\e[48;5;22mr\e[0mk br\e[48;5;22ma\e[0mwn fox\"\n"))
    (unless (= expect (string output))
      (error "Test failed"))))

(test-diff-multi-char)


(t/reset-all!)

(defn test-diff-prefix-suffix []
  (t/deftest test-prefix-suffix
    (t/assert-equal "xxxxxxxxAyyyyyyyy" "xxxxxxxxByyyyyyyy"))
  (let [output @""]
    (with-dyns [:out output :test/color? true]
      (test-prefix-suffix))
    (def expect (string "-----------------------------------\n"
                        "> \e[31mFailed\e[0m: test-prefix-suffix\n"
                        "Assertion: (= \"xxxxxxxxAyyyyyyyy\" \"xxxxxxxxByyyyyyyy\")\n"
                        "Expect (L): \"xxxxxxxx\e[48;5;52mA\e[0myyyyyyyy\"\n"
                        "Actual (R): \"xxxxxxxx\e[48;5;22mB\e[0myyyyyyyy\"\n"))
    (unless (= expect (string output))
      (error "Test failed"))))

(test-diff-prefix-suffix)


(t/reset-all!)

(defn test-diff-multiple-changes []
  (t/deftest test-multiple
    (t/assert-equal "Julia is great" "Janet is awesome"))
  (let [output @""]
    (with-dyns [:out output :test/color? true]
      (test-multiple))
    (def expect (string "-----------------------------------\n"
                        "> \e[31mFailed\e[0m: test-multiple\n"
                        "Assertion: (= \"Julia is great\" \"Janet is awesome\")\n"
                        "Expect (L): \"J\e[48;5;52mulia\e[0m is \e[48;5;52mgreat\e[0m\"\n"
                        "Actual (R): \"J\e[48;5;22manet\e[0m is \e[48;5;22mawesome\e[0m\"\n"))
    (unless (= expect (string output))
      (error "Test failed"))))

(test-diff-multiple-changes)


(t/reset-all!)

(defn test-diff-structures []
  (t/deftest test-structures
    (t/assert-equal [1 2 3] [1 3 3]))
  (let [output @""]
    (with-dyns [:out output :test/color? true]
      (test-structures))
    (def expect (string "-----------------------------------\n"
                        "> \e[31mFailed\e[0m: test-structures\n"
                        "Assertion: (= [1 2 3] [1 3 3])\n"
                        "Expect (L): (1 \e[48;5;52m2\e[0m 3)\n"
                        "Actual (R): (1 \e[48;5;22m3\e[0m 3)\n"))
    (unless (= expect (string output))
      (error "Test failed"))))

(test-diff-structures)


(t/reset-all!)
