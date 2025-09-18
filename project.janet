(def info (-> (slurp "info.jdn") parse))

(declare-project
  :name (info :name)
  :description (info :description)
  :author (info :author)
  :license (info :license)
  :url (info :url)
  :repo (info :repo))

(task "install" []
  (if (bundle/installed? (info :name))
    (bundle/replace (info :name) ".")
    (bundle/install ".")))
