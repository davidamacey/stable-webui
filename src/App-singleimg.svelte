<script>
    // Access the environment variable
    // const API_ENDPOINT = import.meta.env.VITE_API_URL;
    let imageUrl = '';
    let downloadLink = '';
    let textInput = '';
    let isLoading = false;
    let displayedPrompt = ''; // Variable to store the prompt displayed under the image

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

        // Check if the input box is empty
        if (textInput.trim() === '') {
            // Show a warning toast to the user
            toastMessage = 'Please enter text to generate an image.';
            showToast = true;
            toastClass = 'warning'; // Use a warning class for the toast
            setTimeout(() => { showToast = false; }, 3000);
            return; // Exit the function early
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

<main>
    <div class="container">
        <h1>Stable Diffusion XL Text-2-Img</h1>
        <input type="text" bind:value={textInput} placeholder="Enter text here">
        <button on:click={generateImage} disabled={isLoading}>Generate Image</button>
        {#if imageUrl}
            <!-- svelte-ignore a11y-img-redundant-alt -->
            <img src={imageUrl} alt="Generated Image">
            <a href={downloadLink} download="generated_image.png">Download Image</a>
            <p>{displayedPrompt}</p> <!-- Display the prompt below the image -->
        {/if}
        <div class={`toast ${showToast ? 'show' : ''} ${toastClass}`}>{toastMessage}</div>
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
        bottom: 30px;
        font-size: 17px;
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

    @-webkit-keyframes fadein {
        from {bottom: 0; opacity: 0;}
        to {bottom: 30px; opacity: 1;}
    }

    @keyframes fadein {
        from {bottom: 0; opacity: 0;}
        to {bottom: 30px; opacity: 1;}
    }

    @-webkit-keyframes fadeout {
        from {bottom: 30px; opacity: 1;}
        to {bottom: 0; opacity: 0;}
    }

    @keyframes fadeout {
        from {bottom: 30px; opacity: 1;}
        to {bottom: 0; opacity: 0;}
    }
</style>