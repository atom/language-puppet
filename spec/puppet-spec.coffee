describe "Puppet grammar", ->
  grammar = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage("language-puppet")

    runs ->
      grammar = atom.grammars.grammarForScopeName("source.puppet")

  it "parses the grammar", ->
    expect(grammar).toBeTruthy()
    expect(grammar.scopeName).toBe "source.puppet"
