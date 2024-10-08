module GHC.Core.TyCon where

import GHC.Prelude
import GHC.Types.Unique ( Uniquable )
import {-# SOURCE #-} GHC.Types.Name
import GHC.Utils.Outputable

data TyCon

instance Uniquable TyCon
instance Outputable TyCon

type TyConRepName = Name

isNewTyCon          :: TyCon -> Bool
isTupleTyCon        :: TyCon -> Bool
isUnboxedTupleTyCon :: TyCon -> Bool

tyConRepName_maybe  :: TyCon -> Maybe TyConRepName
mkPrelTyConRepName  :: Name -> TyConRepName
tyConName :: TyCon -> Name
