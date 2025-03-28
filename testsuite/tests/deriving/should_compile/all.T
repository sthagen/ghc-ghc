def just_the_deriving( msg ):
  return msg[0:msg.find('Filling in method body')]

test('drv001', normal, compile, [''])
test('drv002', normal, compile, [''])
test('drv003', normal, compile, [''])
test('drv004', normal, compile, [''])
test('drv005', normal, compile, [''])
test('drv006', normal, compile, [''])
test('drv007', normal, compile, [''])
test('drv008', normal, compile, [''])
test('drv009', normal, compile, [''])
test('drv010', normal, compile, [''])
test('drv011', normal, compile, [''])
test('drv012', normal, compile, [''])
test('drv013', normal, compile, [''])
test('drv014', normal, compile, [''])
test('drv015', normal, compile, [''])
test('drv020', normal, compile, [''])
test('drv022', normal, compile, [''])
test('drv023', normal, compile, [''])
test('deriving-1935', normal, compile, [''])
test('T1830_2', normal, compile, [''])
test('T2378', normal, compile, [''])
test('T2721', normal, compile, [''])
test('T2856', normal, compile, [''])
test('T3057', [], multimod_compile, ['T3057', '-v0'])
test('T3012', normal, compile, [''])
test('T3965', normal, compile, [''])
test('T4220', normal, compile, [''])
test('T4302', normal, compile, [''])
test('T4325', normal, compile, [''])
test('T4816', normal, compile, [''])
test('T4966', normal, compile, [''])
test('T5939', normal, compile, [''])

test('drv-functor1', normal, compile, [''])
test('drv-functor2', normal, compile, [''])
test('drv-foldable-traversable1', normal, compile, [''])
test('deriving-via-compile', normal, compile, [''])
test('deriving-via-standalone', normal, compile, [''])
test('T6031', [], multimod_compile, ['T6031', '-v0 -O'])
# Adding -O on T6031 to expose #11245 regardless of way
test('T1133', [], makefile_test, [])
test('T7704', normal, compile, [''])
test('T7710', normal, compile, [''])

test('AutoDeriveTypeable', normal, compile, [''])

test('T8128', normal, compile, [''])
test('T8165', normal, compile, [''])
test('T8631', normal, compile, [''])
test('T8758', [], multimod_compile, ['T8758a', '-v0'])
test('T8678', normal, compile, [''])
test('T8740', normal, compile, [''])
test('T8851', normal, compile, [''])
test('T8865', normal, compile, [''])
test('T8893', normal, compile, [''])
test('T8950', normal, compile, [''])
test('T8963', normal, compile, [''])
test('T7269', normal, compile, [''])
test('T9069', normal, compile, [''])
test('T9359', normal, compile, [''])
test('T4896', normal, compile, [''])
test('T7947', [], multimod_compile, ['T7947', '-v0'])
test('T10561', normal, compile, [''])
test('T10487', [], multimod_compile, ['T10487', '-v0'])
test('T10524', normal, compile, [''])
test('T11068_aggressive', [normalise_errmsg_fun(just_the_deriving)], compile, ['-ddump-deriv -dsuppress-uniques'])
test('T11148', normal, makefile_test, [])
test('T9968', normal, compile, [''])
test('T9968a', normal, compile, [''])
test('T11174', normal, compile, [''])
test('T11416', normal, compile, [''])
test('T11396', normal, compile, [''])
test('T11357', normal, compile, [''])
test('T11509_2', normal, compile, [''])
test('T11509_3', normal, compile, [''])
test('T11732a', normal, compile, [''])
test('T11732b', normal, compile, [''])
test('T11732c', normal, compile, [''])
test('T11833', normal, compile, [''])
test('T12144_1', normal, compile, [''])
test('T12144_2', normal, compile, [''])
test('T12245', normal, compile, [''])
test('T12399', normal, compile, [''])
test('T12423', normal, compile, [''])
test('T12583', normal, compile, [''])
test('T12594', normal, compile, [''])
test('T12616', normal, compile, [''])
test('T12688', normal, compile, [''])
test('T12814', normal, compile, ['-Wredundant-constraints'])
test('T13154a', normal, compile, [''])
test('T13154b', normal, compile, [''])
test('T13272', normal, compile, [''])
test('T13272a', normal, compile, [''])
test('T13297', normal, compile, [''])
test('T13758', normal, compile, [''])
test('drv-empty-data', [normalise_errmsg_fun(just_the_deriving)],compile, ['-ddump-deriv -dsuppress-uniques'])
test('drv-phantom', [normalise_errmsg_fun(just_the_deriving)],compile, ['-ddump-deriv -dsuppress-uniques'])
test('T13813', normal, compile, [''])
test('T13919', normal, compile, [''])
test('T13998', normal, compile, [''])
test('T14045b', normal, compile, [''])
test('T14094', normal, compile, [''])
test('T14331', normal, compile, [''])
test('T14332', normal, compile, [''])
test('T14578', normal, compile, ['-ddump-deriv -dsuppress-uniques'])
test('T14579', normal, compile, ['-ddump-deriv -dsuppress-uniques'])
test('T14579a', normal, compile, [''])
test('T14579b', normal, compile, [''])
test('T14682', normal, compile, ['-ddump-deriv -dsuppress-uniques'])
test('T14883', normal, compile, [''])
test('T14932', normal, compile, [''])
test('T14933', normal, compile, [''])
test('T15073', [extra_files(['T15073a.hs'])], multimod_compile,
               ['T15073', '-v0'])
test('T15290c', normal, compile, [''])
test('T15290d', normal, compile, [''])
test('T15398', normal, compile, [''])
test('T15637', normal, compile, [''])
test('T15831', normal, compile, [''])
test('T16179', normal, compile, [''])
test('T16341', normal, compile, [''])
test('T16518', normal, compile, [''])
test('T17240', normal, compile, ['-ddump-deriv -dsuppress-uniques'])
test('T17324', normal, compile, [''])
test('T17339', normal, compile,
     ['-ddump-simpl -dsuppress-idinfo -dno-typeable-binds'])
test('T17880', normal, compile, [''])
test('T18055', normal, compile, [''])
test('T18321', req_th, compile, [''])
test('T18914', normal, compile, [''])
# We need to find derived instances in the Tc trace dump.
# They are printed in tcDeriv beginning with "rnd" line
# and are indented with spaces.
test('T20496', multiline_grep_errmsg(r"rnd\n( .*\n)*"), compile, ['-ddump-tc-trace'])
test('T20375', normal, compile, [''])
test('T20387', normal, compile, [''])
test('T20501', normal, compile, [''])
test('T20719', normal, compile, [''])
test('T20815', normal, compile, [''])
test('T20994', normal, compile, [''])
test('T22167', normal, compile, [''])
test('T22696a', normal, compile, [''])
test('T22696c', normal, compile, [''])
test('T23329', normal, multimod_compile, ['T23329', '-v0'])
test('T17328', [extra_files(['T17328a.hs'])], multimod_compile, ['T17328', '-v0'])
test('T15798a', normal, compile, [''])
test('T15798b', normal, compile, [''])
test('T15798c', normal, compile, [''])
test('T24955a', normal, compile, [''])
test('T24955b', normal, compile, [''])
test('T24955c', normal, compile, [''])
test('T25148c', normal, compile, [''])
test('deriving-inferred-ty-arg', normal, compile, ['-ddump-deriv -dsuppress-uniques'])
