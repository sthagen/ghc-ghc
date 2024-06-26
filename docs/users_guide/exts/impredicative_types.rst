.. _impredicative-polymorphism:

Impredicative polymorphism
==========================

.. extension:: ImpredicativeTypes
    :shortdesc: Allow impredicative types.

    :implies: :extension:`RankNTypes`
    :since: 9.2.1 (unreliable in 6.10 - 9.0)

    Allow impredicative polymorphic types.

In general, GHC will only instantiate a polymorphic function at a
monomorphic type (one with no foralls). For example, ::

    runST :: (forall s. ST s a) -> a
    id :: forall b. b -> b

    foo = id runST   -- Rejected

The definition of ``foo`` is rejected because one would have to
instantiate ``id``\'s type with ``b := (forall s. ST s a) -> a``, and
that is not allowed. Instantiating polymorphic type variables with
polymorphic types is called *impredicative polymorphism*.

GHC has robust support for *impredicative polymorphism*,
enabled with :extension:`ImpredicativeTypes`, using the so-called Quick Look
inference algorithm.  It is described in the paper
`A quick look at impredicativity
<https://www.microsoft.com/en-us/research/publication/a-quick-look-at-impredicativity/>`__
(Serrano et al, ICFP 2020).

Switching on :extension:`ImpredicativeTypes`

- Switches on :extension:`RankNTypes`

- Allows user-written types to have foralls under type constructors, not just under arrows.
  For example ``f :: Maybe (forall a. [a] -> [a])`` is a legal type signature.

- Allows polymorphic types in Visible Type Application
  (when :extension:`TypeApplications` is enabled).  For example, you
  can write ``reverse @(forall b. b->b) xs``.  Using VTA with a
  polymorphic type argument is useful in cases when Quick Look cannot
  infer the correct instantiation.

- Switches on the Quick Look type inference algorithm, as described
  in the paper.  This allows the compiler to infer impredicative instantiations of polymorphic
  functions in many cases. For example, ``reverse xs`` will typecheck even if ``xs :: [forall a. a->a]``,
  by instantiating ``reverse`` at type ``forall a. a->a``.

Note that the treatment of type-class constraints and implicit parameters remains entirely monomorphic,
even with ImpredicativeTypes. Specifically:

- You cannot apply a type class to a polymorphic type. This is illegal: ``f :: C (forall a. a->a) => [a] -> [a]``

- You cannot give an instance declaration with a polymorphic argument. This is illegal: ``instance C (forall a. a->a)``

- An implicit parameter cannot have a polymorphic type: ``g :: (?x :: forall a. a->a) => [a] -> [a]``

For many years GHC has a special case for the function ``($)``, that allows it
to typecheck an application like ``runST $ (do { ... })``, even though that
instantiation may be impredicative.  This special case remains: even without
:extension:`ImpredicativeTypes` GHC switches on Quick Look for applications of ``($)``.

This flag was available in earlier versions of GHC (6.10.1 - 9.0),
but the behavior was unpredictable and not officially supported.
