<template>
    <div class="game-hud">
        <div v-if="store.gameActive" class="game-header">
            <h1>Polka-Dash</h1>
            <div class="sub-heading">DASH to the END!</div>
        </div>

        <div v-if="store.gameActive" class="stats-bar">
            <div class="level">
                <span>Distance</span>
                <div class="level-value">{{ store.distance }}</div>
            </div>

            <div class="score">
                <div class="level">
                    <span>Score</span>
                    <div class="level-value">{{ store.score }}</div>
                </div>
            </div>
            <div class="score">
                <div class="level">
                    <span>Address</span>
                    <div class="level-value">{{ updateAddress() }}</div>
                </div>
            </div>
        </div>

        <!-- Game Over Menu -->
        <div v-if="!store.gameActive" class="menu-overlay">
            <div class="game-over-menu">
                <h2>Game Over</h2>
                <p class="level-value">Your Score: {{ store.score }}</p>
                <p class="level-value">Your Distance: {{ store.distance }}</p>
                <button @click="restart">Restart</button>
                <button @click="continueGame">Continue</button>
            </div>
        </div>
        <!-- Start Menu -->
        <div v-if="store.showMenu" class="menu-overlay">
            <div class="game-over-menu">
                <h2 class="level-value">Welcome</h2>
                <button class="level-value" @click="play">Play</button>
            </div>
        </div>
    </div>
</template>

<script setup lang="ts">
import { useGameStore } from '../stores/gamestore'
import { onMounted, inject, ref } from 'vue'
const store = useGameStore()
const progress: any = inject("progress");
const submitScore = () => {
    console.log("submitting score", store.score)
}
const play = () => {
    store.showMenu = false
    connectWallet()
}
const continueGame = () => {
    console.log("continue")
}
const restart = () => {
    store.restart = true
    console.log("restart", store.restart)
}
const connectWallet = async () => {
    // Initialise the provider to connect to the local node
    progress.start();
    progress.finish();
}
const updateAddress = (): string => {
    return store.address.length > 0 ? store.address.substring(0, 3) + "..." + store.address.substring(store.address.length - 3, store.address.length) : "Connect Wallet"
}
onMounted(() => {
    console.log("mounted: ", store.showMenu)
    store.gameActive = false
    store.canDash = false
})
</script>
<style scoped>
.main-container {
    position: relative;
    width: 100vw;
    height: 100vh;
    overflow: hidden;
}

.game-container {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
}

.game-hud {
    position: fixed;
    top: 10%;
    right: 35%;
    width: 100%;
    height: 100%;
    pointer-events: none;
    z-index: 50;
}

.game-header {
    text-align: center;
    margin-bottom: 1rem;
    padding-top: 1rem;
}

.game-header h1 {
    font-family: 'Georgia', serif;
    font-weight: 400;
    font-size: 2.5rem;
    letter-spacing: 0.1em;
    color: black;
    margin: 0;
}

.sub-heading {
    font-size: 1rem;
    letter-spacing: 0.2em;
    color: black;
}

.stats-bar {
    display: flex;
    justify-content: center;
    align-items: center;
    background-color: var(--bg-light, #f8e5d1);
    padding: 1rem;
    border-radius: 30px;
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
    gap: 2rem;
    margin: 0 auto;
    width: fit-content;
    pointer-events: all;
}

.menu-overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    display: flex;
    justify-content: center;
    align-items: center;
    background-color: rgba(0, 0, 0, 0.5);
    pointer-events: all;
}

.game-over-menu {
    background: white;
    padding: 2rem;
    border-radius: 20px;
    box-shadow: 0 8px 16px rgba(0, 0, 0, 0.2);
    width: 80%;
    max-width: 400px;
    text-align: center;
}

.game-over-menu h2 {
    font-size: 2rem;
    margin: 0 0 1rem;
    color: var(--primary-color, #c09b79);
}

.game-over-menu button {
    background-color: var(--text-dark, #6e5339);
    color: white;
    border: none;
    border-radius: 10px;
    padding: 10px 20px;
    font-size: 1rem;
    cursor: pointer;
    transition: background-color 0.3s ease;
    margin: 0.5rem;
}

.game-over-menu button:hover {
    background-color: var(--secondary-color, #b17f6a);
}

.level {
    color: #000;
}

.level-value {
    color: #000;
}

/* Mobile layout */
@media (max-width: 768px) {
    .game-header h1 {
        font-size: 1.5rem;
    }

    .sub-heading {
        font-size: 0.8rem;
    }

    .stats-bar {
        max-width: 90%;
        padding: 0.5rem;
    }

    .game-over-menu {
        width: 90%;
        padding: 1.5rem;
    }
}
</style>