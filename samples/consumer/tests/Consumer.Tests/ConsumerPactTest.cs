using System.Net;
using System.Net.Http;
using System.Threading.Tasks;
using Consumer.ApiClient;
using PactNet;
using Xunit;

namespace Consumer.Tests
{
    public class ConsumerPactTest
    {
        private readonly IPactBuilderV4 _pactBuilder;

        public ConsumerPactTest()
        {
            var config = new PactConfig
            {
                PactDir = "../../../../../pacts",
                LogLevel = PactLogLevel.Information
            };

            // Define the pact
            var pact = Pact.V4("Consumer", "Provider", config);
            _pactBuilder = pact.WithHttpInteractions();
        }

        [Fact]
        public async Task GetProduct_WhenProductExists_ReturnsProduct()
        {
            // Arrange
            _pactBuilder
                .UponReceiving("A request to get a product")
                    .Given("product with ID 10 exists")
                    .WithRequest(HttpMethod.Get, "/api/products/10")
                .WillRespond()
                    .WithStatus(HttpStatusCode.OK)
                    .WithHeader("Content-Type", "application/json; charset=utf-8")
                    .WithJsonBody(new
                    {
                        id = 10,
                        name = "28 Degrees",
                        type = "Credit Card"
                    });

            await _pactBuilder.VerifyAsync(async ctx =>
            {
                // Act
                using var httpClient = new HttpClient { BaseAddress = ctx.MockServerUri };
                var client = new ProductsClient(httpClient);
                var product = await client.GetProduct(10);

                // Assert
                Assert.Equal(10, product.Id);
                Assert.Equal("28 Degrees", product.Name);
                Assert.Equal("Credit Card", product.Type);
            });
        }
    }
}
