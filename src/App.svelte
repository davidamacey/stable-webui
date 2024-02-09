<script>
    // Access the environment variable
    // const API_ENDPOINT = import.meta.env.VITE_API_URL;
    let imageUrl = '';
    let downloadLink = '';
    let textInput = '';
    let isLoading = false;
    let displayedPrompt = ''; // Variable to store the prompt displayed under the image
    let showModal = false;

    // This code runs when the component is created
    localStorage.clear();
    sessionStorage.clear();

    function openModal() {
        showModal = true;
    }

    function closeModal() {
        showModal = false;
    }

    function handleModalClick(event) {
        // Close the modal if the clicked element is the modal background itself
        if (event.target.classList.contains('modal')) {
            closeModal();
        }
    }

    function handleKeyDown(event) {
        if (event.key === 'Enter') {
            openModal();
        }
    }

    // New function to show error toast
    function showErrorToast() {
        toastMessage = 'API is not available. Please try again later.';
        showToast = true;
        // Using a danger class to style the toast for errors
        toastClass = 'danger';
        setTimeout(() => { showToast = false; }, 3000);
    }

    let toastClass = ''; // New variable to handle toast styling

    async function generateImage() {

        if (prompt === '') {
            toastMessage = 'Please enter text to generate an image.';
            showToast = true;
            toastClass = 'warning';
            setTimeout(() => { showToast = false; }, 3000);
            return;
        }
        
        try {
            isLoading = true;
            showProcessingToast();
            // comment here
            const response = await fetch('http://192.168.30.11:8600/generate/', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ prompt: textInput }),
            });

            if (!response.ok) { // Check if the response status is not OK
                throw new Error('Network response was not ok');
            }

            const data = await response.json();

            // Updated to handle PNG images
            imageUrl = `data:image/png;base64,${data.image}`;
            downloadLink = imageUrl; // Using the same data URI for the download link
            displayedPrompt = textInput; 
            textInput = ''; 

            showCompletionToast();
            isLoading = false;
        } catch (error) {
            console.error('There was a problem with the fetch operation:', error);
            showErrorToast();
            isLoading = false;
            // Do not clear textInput here, so it remains in the input box
        } finally {
            isLoading = false;
        }
    }

    let showToast = false;
    let toastMessage = '';

    function showProcessingToast() {
        toastMessage = 'Processing image...';
        showToast = true;
        setTimeout(() => { showToast = false; }, 3000);
    }

    function showCompletionToast() {
        toastMessage = 'Image ready!';
        showToast = true;
        setTimeout(() => { showToast = false; }, 3000);
    }

</script>

<svelte:head>
    <title>SD txt2img</title>
</svelte:head>

<main>
    <div class="container">
        <h1>Stable Diffusion XL Text-2-Img</h1>
        <input type="text" bind:value={textInput} placeholder="Enter text here" class="narrow-input">
        <button on:click={generateImage} disabled={isLoading}>
            {#if isLoading}
                <div class="spinner"></div> <!-- Spinner icon -->
            {:else}
                Generate Image
            {/if}
        </button>
        {#if imageUrl}
            <!-- Ensure the click handler is correctly bound -->
            <div on:click={openModal} class="image-container">
                <img src={imageUrl} alt="Generated Image" class="thumbnail">
            </div>
            <p class="displayed-prompt">{displayedPrompt}</p>
        {/if}

        <!-- Use reactive statements to control the display of modal -->
        {#if showModal}
            <div class="modal" on:click={handleModalClick} style="display: {showModal ? 'block' : 'none'};">
                <div class="modal-content" on:click|stopPropagation>
                    <span class="close-button" on:click={closeModal}>&times;</span>
                    <img src={imageUrl} alt="Full-size Image">
                    <a href={downloadLink} download="generated_image.png" class="download-button">⬇️</a>
                </div>
            </div>
        {/if}
        <div class={`toast ${showToast ? 'show' : ''} ${toastClass}`}>{toastMessage}</div>
        <footer>
            <p>Copyright &copy; 2024</p>
            <p>Created by David A. Macey</p>
            <a href="https://github.com/davidamacey" target="_blank">GitHub</a>
        </footer>
    </div>
</main>

<style>
    :global(body) {
        color: #fff;
        background-color: #121212;
        font-family: Arial, sans-serif;
    }

    .container {
        text-align: center;
        padding: 20px;
        padding-bottom: 50px; /* Adjust as necessary */
    }

    input[type="text"] {
        color: #333;
        padding: 10px;
        margin: 10px 0;
        width: 80%; /* Adjust as needed */
    }

    button {
        background-color: #1a73e8;
        color: white;
        border: none;
        padding: 10px 20px;
        margin: 10px;
        cursor: pointer;
    }

    img {
        max-width: 100%;
        height: auto;
        margin-top: 20px;
    }

	p {
        color: #fff;
        margin-top: 20px;
    }

    .toast {
        visibility: hidden;
        min-width: 250px;
        margin-left: -125px;
        background-color: #333;
        color: #fff;
        text-align: center;
        border-radius: 2px;
        padding: 16px;
        position: fixed;
        z-index: 1;
        left: 50%;
        top: 30px;
        font-size: 17px;
        bottom: auto;
    }

    .toast.danger {
        background-color: red; /* Example styling for danger toast */
        color: white;
    }

    .toast.warning {
        background-color: orange; /* Example styling for warning toast */
        color: white;
    }

    .show {
        visibility: visible;
        -webkit-animation: fadein 0.5s, fadeout 0.5s 2.5s;
        animation: fadein 0.5s, fadeout 0.5s 2.5s;
    }

    .narrow-input {
        width: auto; /* Change from fixed width to auto */
        max-width: 30%; /* Ensure it doesn't become too small */
        min-width: 10%;
    }

    .thumbnail {
        max-width: 30%; /* Adjust for smaller image display */
        cursor: pointer;
    }

    .displayed-prompt {
        color: #ddd;
        font-style: italic;
        margin-top: 10px;
    }

    .modal {
        display: none; /* Hidden by default */
        position: fixed;
        z-index: 2;
        left: 0;
        top: 0;
        width: 100%;
        height: 100%;
        overflow: auto;
        background-color: rgba(0, 0, 0, 0.4);
    }

    .modal-content {
        background-color: #333;
        color: #fff;
        margin: 4% auto;
        padding: 20px;
        border: 1px solid #888;
        width: 85%;
        position: relative;
    }

    .close-button {
        color: #aaa;
        float: left;
        font-size: 28px;
        font-weight: bold;
    }

    .close-button:hover,
    .close-button:focus {
        color: black;
        text-decoration: none;
        cursor: pointer;
    }

    .download-button {
        position: absolute;
        top: 10px;
        right: 10px;
        font-size: 24px;
        color: white;
        text-decoration: none;
    }

    /* Sticky Footer CSS */
    footer {
        text-align: center;
        padding: 10px;
        color: #666; /* Adjust the color to ensure readability */
        position: fixed;
        bottom: 0;
        width: 100%;
        font-size: 14px;
        background-color: transparent; /* Remove background color */
    }

    footer p, footer a {
        margin: 0;
        padding: 3px;
        color: inherit; /* Footer text color */
        text-decoration: none;
    }

    footer a:hover {
        text-decoration: underline;
    }




    @-webkit-keyframes fadein {
        from {top: 0; opacity: 0;}
        to {top: 30px; opacity: 1;}
    }

    @keyframes fadein {
        from {top: 0; opacity: 0;}
        to {top: 30px; opacity: 1;}
    }

    @-webkit-keyframes fadeout {
        from {top: 30px; opacity: 1;}
        to {top: 0; opacity: 0;}
    }

    @keyframes fadeout {
        from {top: 30px; opacity: 1;}
        to {top: 0; opacity: 0;}
    }

    .spinner {
        border: 4px solid rgba(255, 255, 255, 0.3);
        border-radius: 50%;
        border-top: 4px solid #fff;
        width: 20px;
        height: 20px;
        -webkit-animation: spin 2s linear infinite; /* Safari */
        animation: spin 2s linear infinite;
    }

    /* Safari */
    @-webkit-keyframes spin {
        0% { -webkit-transform: rotate(0deg); }
        100% { -webkit-transform: rotate(360deg); }
    }

    @keyframes spin {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
    }

</style>