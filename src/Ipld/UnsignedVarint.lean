import Ipld.Utils

def toVarIntCore : Nat → Nat → ByteArray → ByteArray
| 0, n, bytes => bytes
| fuel+1, n, bytes =>
      let b: UInt8 := UInt8.ofNat (n % 128);
      let n' := n / 128;
      if n' = 0 then (bytes.push b)
      else toVarIntCore fuel n' (bytes.push (b + 128))

def toVarInt (n: Nat) : ByteArray := 
  toVarIntCore (n+1) n { data := #[] }

def fromVarInt (b: ByteArray) : Nat := Id.run do
  let mut x := 0
  for i in [:b.size] do
    x := x + Nat.shiftLeft (UInt8.toNat b.data[i] % 128) (i * 7)
  return x

instance : BEq ByteArray where
  beq a b := a.data == b.data

--#eval fromVarInt (toVarInt 1) == 1
--#eval (toVarInt 127) == { data := #[0b01111111] }
--
--#reduce fromVarInt (toVarInt 1) = 1 
--
--#eval fromVarInt (toVarInt 127) == 127
--#eval toVarInt 255 
--#eval (toVarInt 255 == { data := #[0b11111111, 0b00000001] })
--#eval (toVarInt 255 == { data := #[0b01111111, 0b00000001] })
--#eval fromVarInt (toVarInt 255) == 255
--#eval (toVarInt 300 == { data := #[0b10101100, 0b00000010] })
--#eval fromVarInt (toVarInt 300) == 300
--#eval (toVarInt 16384 == { data := #[0b10000000, 0b10000000, 0b00000001] })
--#eval fromVarInt (toVarInt 16384) == 16384
