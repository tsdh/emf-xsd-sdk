(defproject emf-xsd-sdk "2.7.1"
  :description "The Eclipse Modeling Framework SDK bundle.

  For EMF, see http://www.eclipse.org/modeling/emf/.

  This is an inofficial bundle of EMF release JARs for simple usage by
  Maven-based projects."
  :url "https://github.com/tsdh/emf-xsd-sdk"
  ;; Where are the EMF jars?
  :library-path "emf-jars"
  :jar-exclusions [#"(\.git/|PUT_EMF_SDK_JARS_HERE|examples)"]
  :uberjar-exclusions [#"(\.git/|PUT_EMF_SDK_JARS_HERE|examples|tutorials|cheatsheets|references)"])