------------------------------------------------------------------------------
--                                                                          --
--                       Copyright (C) 2018, AdaCore                        --
--                                                                          --
--  Redistribution and use in source and binary forms, with or without      --
--  modification, are permitted provided that the following conditions are  --
--  met:                                                                    --
--     1. Redistributions of source code must retain the above copyright    --
--        notice, this list of conditions and the following disclaimer.     --
--     2. Redistributions in binary form must reproduce the above copyright --
--        notice, this list of conditions and the following disclaimer in   --
--        the documentation and/or other materials provided with the        --
--        distribution.                                                     --
--     3. Neither the name of the copyright holder nor the names of its     --
--        contributors may be used to endorse or promote products derived   --
--        from this software without specific prior written permission.     --
--                                                                          --
--   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS    --
--   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT      --
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR  --
--   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT   --
--   HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, --
--   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT       --
--   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,  --
--   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY  --
--   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT    --
--   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE  --
--   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.   --
--                                                                          --
------------------------------------------------------------------------------

with MicroBit.Music; use MicroBit.Music;

procedure Main is

   My_Little_Melody : constant MicroBit.Music.Melody :=
   ((C4,   400),
   (G3,   800),
   (B3,   400),
   (Rest, 400),
   (A3,   400),
   (G3,   400));

   Music_KnightRider : constant MicroBit.Music.Melody :=
   ((A4, 250), (AS4, 125), (A4, 125),
   (A4, 125), (AS4, 125), (A4, 125), (A4, 125),
   (AS4, 125), (A4, 125), (A4, 125), (A4, 125),
   (GS4, 125), (A4, 125), (A4, 125), (A4, 125),
   (A4, 250), (AS4, 125), (A4, 125),
   (A4, 125), (AS4, 125), (A4, 125), (A4, 125),
   (AS4, 125), (A4, 125), (A4, 125), (A4, 125),
   (GS4, 125), (A4, 125), (A4, 125), (A4, 125),
   (G4, 250), (GS4, 125), (G4, 125),
   (G4, 125), (GS4, 125), (G4, 125), (G4, 125),
   (GS4, 125), (G4, 125), (G4, 125), (G4, 125),
   (FS4, 125), (G4, 125), (G4, 125), (G4, 125),
   (G4, 250), (GS4, 125), (G4, 125),
   (G4, 125), (GS4, 125), (G4, 125), (G4, 125),
   (GS4, 125), (G4, 125), (G4, 125), (G4, 125),
   (FS4, 125), (G4, 125), (G4, 125), (G4, 125),

   (A4, 250), (AS4, 125), (A4, 125),
   (A4, 125), (AS4, 125), (A4, 125), (A4, 125),
   (AS4, 125), (A4, 125), (A4, 125), (A4, 125),
   (GS4, 125), (A4, 125), (A4, 125), (A4, 125),
   (A4, 250), (AS4, 125), (A4, 125),
   (A4, 125), (AS4, 125), (A4, 125), (A4, 125),
   (AS4, 125), (A4, 125), (A4, 125), (A4, 125),
   (GS4, 125), (A4, 125), (A4, 125), (A4, 125),
   (G4, 250), (GS4, 125), (G4, 125),
   (G4, 125), (GS4, 125), (G4, 125), (G4, 125),
   (GS4, 125), (G4, 125), (G4, 125), (G4, 125),
   (FS4, 125), (G4, 125), (G4, 125), (G4, 125),
   (G4, 250), (GS4, 125), (G4, 125),
   (G4, 125), (GS4, 125), (G4, 125), (G4, 125),
   (GS4, 125), (G4, 125), (G4, 125), (G4, 125),
   (FS4, 125), (G4, 125), (G4, 125), (G4, 125),

   (A4, 250), (AS4, 125), (A4, 125),
   (A4, 125), (AS4, 125), (A4, 125), (A4, 125),
   (AS4, 125), (A4, 125), (A4, 125), (A4, 125),
   (GS4, 125), (A4, 125), (A4, 125), (A4, 125),
   (A4, 250), (AS4, 125), (A4, 125),
   (A4, 125), (AS4, 125), (A4, 125), (A4, 125),
   (AS4, 125), (A4, 125), (A4, 125), (A4, 125),
   (GS4, 125), (A4, 125), (A4, 125), (A4, 125),
   (G4, 250), (GS4, 125), (G4, 125),
   (G4, 125), (GS4, 125), (G4, 125), (G4, 125),
   (GS4, 125), (G4, 125), (G4, 125), (G4, 125),
   (FS4, 125), (G4, 125), (G4, 125), (G4, 125),
   (G4, 250), (GS4, 125), (G4, 125),
   (G4, 125), (GS4, 125), (G4, 125), (G4, 125),
   (GS4, 125), (G4, 125), (G4, 125), (G4, 125),
   (FS4, 125), (G4, 125), (G4, 125), (G4, 125),


   (A4, 250), (AS4, 125), (A4, 125), (E5, 1500),
   (A5, 250), (AS5, 125), (A5, 125), (E5, 1500),
   (A4, 250), (AS4, 125), (A4, 125), (E5, 250), (A5, 250), (G5, 2000),
   (A4, 250), (AS4, 125), (A4, 125), (E5, 1500),
   (A5, 250), (AS5, 125), (A5, 125), (E5, 1500),
   (A4, 250), (AS4, 125), (A4, 125), (E5, 250), (A5, 250), (AS5, 2500), (G5, 250), (A5, 500));

--  Play music on the internal speaker at max volume and on repeat
begin
   loop
      MicroBit.Music.Play (27, Music_KnightRider);
   end loop;
end Main;
