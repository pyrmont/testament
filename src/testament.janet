(var- num-tests-run 0)
(var- num-tests-passed 0)


(var- tests @[])
(var- reports @[])


(defn- make-report [result]
  (let [latest (last reports)
        queue  (if (result :passed?) (latest :passes) (latest :failures))]
    (array/push queue result)))


(defn- review-assertion
  [passed? report note]
  (++ num-tests-run)
  (if passed?
    (++ num-tests-passed))
  (let [summary {:passed? passed? :report report :note note}]
    (if (empty? reports)
      summary
      (make-report summary))))


(defn- add-test
  [t]
  (array/push tests t))


(defn- start-report
  [name]
  (array/push reports @{:name name :passes @[] :failures @[]}))


(defn- print-report
  []
  (each report reports
    (unless (empty? (report :failures))
      (do
        (print "\n> Failed: " (report :name))
        (each failure (report :failures)
          (print "Assertion: " (failure :note))
          (print (failure :report))))))
  (let [stats (string num-tests-run " tests run, "
                      num-tests-passed " tests passed, "
                      (- num-tests-run num-tests-passed) " tests failed")]
    (print)
    (print (string/repeat "-" (length stats)))
    (print stats)
    (print (string/repeat "-" (length stats)))))


(defn- which
  [assertion]
  (cond
    (and (tuple? assertion) (= 3 (length assertion)) (= '= (first assertion))) :equal
    :else :expr))


(defmacro assert-expr
  [expr &opt note]
  (with-syms [$expr $report $note]
    ~(let [$expr ,expr
           $report (if $expr "Passed" "Reason: Result is boolean false")
           $note (or ,note (string/format "%q" ',expr))]
      (,review-assertion $expr $report $note))))


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


(defmacro is
  [assertion &opt note]
  (case (which assertion)
    :equal (let [[_ expect actual] assertion]
             ~(assert-equal ,expect ,actual ,note))
    :expr ~(assert-expr ,assertion ,note)))


(defmacro deftest
  [name & body]
  ~(splice [(defn ,name [] (,start-report ',name) ,;body)
            (,add-test (or ,name ',name))]))


(defn run-tests!
  []
  (each test tests ((or (get (dyn test) :value)
                        test)))
  (print-report)
  (unless (= num-tests-run num-tests-passed)
    (os/exit 1)))


(defn reset-tests!
  []
  (set num-tests-run 0)
  (set num-tests-passed 0)
  (set tests @[])
  (set reports @[]))
