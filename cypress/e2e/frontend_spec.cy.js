// Writing first cypress test
describe('Frontend Tests', () => {
    it('Should load the index page', () => {
        cy.visit('http://raviki.online');
    })

    it('Should load the visitor count', () => {
        cy.visit('http://raviki.online');
        //locate the visitor count element
        cy.get('#footer').should('be.visible');
    })
})