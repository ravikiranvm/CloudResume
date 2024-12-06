document.addEventListener('DOMContentLoaded', function(){
    fetch('https://sk1fiixme1.execute-api.ap-south-1.amazonaws.com/prod/visitor_count')
    .then(response => response.json())
    .then(data => {
        let visitor_count = data.updated_total_count;

        document.querySelector('#footer').innerHTML = `This resume caught the eye of ${visitor_count} cusrious minds.`;
    })
    .catch(error => {
        console.log('Error:', error);
    });
});