(var- num-tests-run 0)
(var- num-tests-passed 0)


(def- tests @[])
(def- reports @[])


(defn- make-report [result]
  (let [latest (last reports)
        queue  (if (result :passed?) (latest :passes) (latest :failures))]
    (array/push queue result)))


(defn- review-assertion
  [passed? report note]
  (++ num-tests-run)
  (if passed?
    (++ num-tests-passed))
  (make-report {:passed? passed? :report report :note note}))


(defn- add-test
  [t]
  (array/push tests t))


(defn- run-test
  [& forms]
  (do ;forms))


(defn- start-report
  [name]
  (array/push reports @{:name name :passes @[] :failures @[]}))


(defn- print-report
  []
  (each report reports
    (unless (empty? (report :failures))
      (do
        (print "Failed: " (report :name) "\n")
        (each failure (report :failures)
          (print "Assertion: " (failure :note))
          (print (failure :report) "\n")))))
  (let [stats (string num-tests-run " tests run, "
                      num-tests-passed " tests passed, "
                      (- num-tests-run num-tests-passed) " tests failed")]
    (print (string/repeat "-" (length stats)))
    (print stats)
    (print (string/repeat "-" (length stats)))))


(defmacro assert-equal
  [expect actual &opt note]
  (with-syms [$expect $actual $result $report $note]
    ~(let [$expect ,expect
           $actual ,actual
           $result (,= $expect $actual)
           $report (if $result "Passed"
                               (string "Expected: " (string/format "%q\n" $expect)
                                       "Actual: " (string/format "%q" $actual)))
           $note   (or ,note (string/format "%q" ',actual))]
       (,review-assertion $result $report $note))))


(defmacro deftest
  [name & body]
  # ~(do
  #    (defn ,name []
  #      (,start-report ',name)
  #      (,run-test ,;body))
  #    (,add-test ,name)))
  ~(,add-test ,name)
  ~(defn ,name []
     (,start-report ',name)
     (,run-test ,;body)))


(defn run-tests!
  []
  (each test tests (test))
  (print-report)
  (unless (= num-tests-run num-tests-passed)
    (os/exit 1)))
