(def- seps {:windows "\\" :mingw "\\" :cygwin "\\"})
(def- s (get seps (os/which) "/"))

# used for splitting POSIX paths
(def- posix-pathg ~{:main     (* (+ :abspath :relpath) (? :sep) -1)
                    :abspath  (* :root (any :relpath))
                    :relpath  (* :part (any (* :sep :part)))
                    :root     (* "/" (constant ""))
                    :sep      (some "/")
                    :part     '(some (* (! :sep) 1))})

# based on code from spork/declare-cc.janet
(defn- add-bat-shim [manifest bin-name &opt chmod-mode]
  (def binpath (string (dyn :syspath) s "bin"))
  (def bin-dest (string binpath s bin-name))
  (assert (= :file (os/stat bin-dest :mode)) "must call bundle/add-bin first")
  (def bat-name (string bin-name ".bat"))
  (def files (get manifest :files)) # guaranteed to be non-nil
  (def dest (string binpath s bat-name))
  (when (os/stat dest :mode)
    (errorf "collision at %s, file already exists" dest))
  (def bat (string "@echo off\r\n"
                   "goto #_undefined_# 2>NUL || title %COMSPEC% & janet \""
                   bin-dest
                   "\" %*"))
  (spit dest bat)
  (def absdest (os/realpath dest))
  (array/push files absdest)
  (when chmod-mode
    (os/chmod absdest chmod-mode))
  (print "add " absdest))

(defn- split-posix-path [path]
  (peg/match posix-pathg path))

(defn- add-path [paths dest &opt src]
  (def bits (split-posix-path dest))
  (assert bits "invalid path")
  (def ks @[])
  (each b bits
    (array/push ks b)
    (unless (get-in paths ks)
      (put-in paths ks @{})))
  (when src
    (put-in paths ks (-> (split-posix-path src)
                         (string/join s)))))

(defn- install-libs [manifest &]
  (def to-make @{})
  (def libs (get-in manifest [:info :artifacts :libraries] []))
  (each lib libs
    (def ks @[])
    (def prefix (get lib :prefix))
    (when prefix (add-path to-make prefix))
    (def paths (get lib :paths))
    (each p paths
      # use POSIX path separator to match info file
      (add-path to-make (string (when prefix (string prefix "/")) p) p)))
  (defn add-tree [tree path]
    (eachp [k v] tree
      (if (table? v)
        (do
          (def new-path (if (empty? path) k (string path s k)))
          (bundle/add-directory manifest new-path)
          (add-tree v new-path))
        (bundle/add manifest v (string path s k)))))
  (add-tree to-make ""))

(defn- install-mans [manifest &]
  (def mans (get-in manifest [:info :artifacts :manpages] []))
  (each m mans
    (def bits (split-posix-path m))
    (var dir (dyn :syspath))
    (each b (array/slice bits 0 -2)
      (set dir (string dir s b))
      (os/mkdir dir))
    (bundle/add-file manifest (string/join bits s))))

(defn- install-scrs [manifest &]
  (def scrs (get-in manifest [:info :artifacts :scripts] []))
  (each scr scrs
    (def path (-> (get scr :path)
                  (split-posix-path)
                  (string/join s)))
    (bundle/add-bin manifest path)
    (when (= "\\" s)
      (def bin-name (last (string/split s path)))
      (add-bat-shim manifest bin-name))))

(defn- set-version [manifest]
  (def bundle-ver (get-in manifest [:info :version]))
  (if (not= "DEVEL" bundle-ver)
    (put manifest :version bundle-ver)
    (do
      (def src (get manifest :local-source))
      (def [r w] (os/pipe))
      (def [ok? res] (protect (os/execute ["git" "-C" src "describe" "--always" "--dirty"] :px {:out w :err w})))
      (:close w)
      (put manifest
           :version
           (if ok?
             (string bundle-ver "-" (string/trim (ev/read r :all)))
             bundle-ver)))))

(defn install [manifest &]
  (install-libs manifest)
  (install-mans manifest)
  (install-scrs manifest)
  (set-version manifest))
