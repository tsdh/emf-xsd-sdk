(defproject emf-xsd-sdk "2.11.1"
  :description "The Eclipse Modeling Framework SDK bundle.

  For EMF, see http://www.eclipse.org/modeling/emf/.

  This is an inofficial bundle of EMF release JARs for simple usage by
  Maven-based projects."
  :url "https://github.com/tsdh/emf-xsd-sdk"
  :license {:name "Eclipse Public License"
            :url "http://www.eclipse.org/legal/epl-v10.html"}
  ;; Where are the EMF class files?
  :filespecs [{:type :path :path "emf-jars"}]
  :jar-exclusions [#"(PUT_EMF_SDK_JARS_HERE|toc.xml|readme.html)"
                   #"about\.(html|ini|properties|mappings)"
                   #"plugin\.(xml|properties)"
                   #".*\.(sf|dsa|rsa|SF|RSA|DSA|jar|options|api_description|java|gif|png)$"
                   #"^(\.git/|examples/|tutorials/|cheatsheets/|references/|index/|schema/|rose/|images/|icons/|css/|templates/|cache/|model/|about_files/)"])
