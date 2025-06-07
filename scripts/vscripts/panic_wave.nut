DirectorOptions <-
{
	A_CustomFinale_StageCount = 2 // two stages for this event
	A_CustomFinale1 = 0 // 0 == PANIC
	A_CustomFinaleValue1 = 1 // 1 wave

	// delay for 30 fucking thousand years
	// to prevent a second horde from spawning
	A_CustomFinale2 = 2 // 2 == DELAY
	A_CustomFinaleValue2 = 10000000 // time to switch to next stage
}