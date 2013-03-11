(defproject emf-xsd-sdk "2.8.3"
  :description "The Eclipse Modeling Framework SDK bundle.

  For EMF, see http://www.eclipse.org/modeling/emf/.

  This is an inofficial bundle of EMF release JARs for simple usage by
  Maven-based projects."
  :url "https://github.com/tsdh/emf-xsd-sdk"
  ;; Where are the EMF class files?
  :filespecs [{:type :path :path "emf-jars"}]
  :jar-exclusions [#"(\.git/|PUT_EMF_SDK_JARS_HERE)"]
  :uberjar-exclusions [#"(PUT_EMF_SDK_JARS_HERE|toc.xml|readme.html)"
                       #"about\.(html|ini|properties|mappings)"
                       #"plugin\.(xml|properties)"
                       #".*\.(sf|dsa|rsa|SF|RSA|DSA|jar|options|api_description|java|gif|png)$"
                       #"^(\.git/|examples/|tutorials/|cheatsheets/|references/|index/|schema/|rose/|images/|icons/|css/|templates/|cache/|model/|about_files/)"])
