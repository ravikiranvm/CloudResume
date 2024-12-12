document.addEventListener('DOMContentLoaded', function(){
    fetch('https://j0iyjzewml.execute-api.ap-south-1.amazonaws.com/prod/visitor_count')
    .then(response => response.json())
    .then(data => {
        let visitor_count = data.updated_total_count;

        document.querySelector('#footer').innerHTML = `This resume caught the eye of ${visitor_count} curious minds!`;
    })
    .catch(error => {
        console.log('Error:', error);
    });
});