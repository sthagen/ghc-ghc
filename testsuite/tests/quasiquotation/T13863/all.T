test('T13863', [req_th, omit_ways(prof_ways), extra_files(['A.hs', 'B.hs'])], multimod_compile, ['B', '-fno-code -v0'])
