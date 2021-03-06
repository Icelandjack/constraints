{-# LANGUAGE CPP #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE ConstraintKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE Rank2Types #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE Unsafe #-}
-----------------------------------------------------------------------------
-- |
-- Module      :  Data.Constraint.Unsafe
-- Copyright   :  (C) 2011-2015 Edward Kmett
-- License     :  BSD-style (see the file LICENSE)
--
-- Maintainer  :  Edward Kmett <ekmett@gmail.com>
-- Stability   :  experimental
-- Portability :  non-portable
--
----------------------------------------------------------------------------
module Data.Constraint.Unsafe
  ( Coercible
  , unsafeCoerceConstraint
  , unsafeDerive
  , unsafeUnderive
  -- * Sugar
  , unsafeApplicative
  , unsafeAlternative
  ) where

import Control.Applicative
import Control.Monad
import Data.Constraint
import Unsafe.Coerce

#if __GLASGOW_HASKELL__ >= 708

import Data.Coerce

#else

import Control.Newtype

type Coercible = Newtype

#endif

-- | Coerce a dictionary unsafely from one type to another
unsafeCoerceConstraint :: a :- b
unsafeCoerceConstraint = unsafeCoerce refl

-- | Coerce a dictionary unsafely from one type to a newtype of that type
unsafeDerive :: Coercible n o => (o -> n) -> t o :- t n
unsafeDerive _ = unsafeCoerceConstraint

-- | Coerce a dictionary unsafely from a newtype of a type to the base type
unsafeUnderive :: Coercible n o => (o -> n) -> t n :- t o
unsafeUnderive _ = unsafeCoerceConstraint

-- | Construct an Applicative instance from a Monad
unsafeApplicative :: forall m a. Monad m => (Applicative m => m a) -> m a
unsafeApplicative m = m \\ trans (unsafeCoerceConstraint :: Applicative (WrappedMonad m) :- Applicative m) ins

-- | Construct an Alternative instance from a MonadPlus
unsafeAlternative :: forall m a. MonadPlus m => (Alternative m => m a) -> m a
unsafeAlternative m = m \\ trans (unsafeCoerceConstraint :: Alternative (WrappedMonad m) :- Alternative m) ins
