# Tests unloading an object file which is in use in a thread
test('T16525b', [when(opsys('mingw32'), fragile(20852)), extra_files(['A.hs', 'B.hs'])], ghci_script, ['T16525b.script'])
