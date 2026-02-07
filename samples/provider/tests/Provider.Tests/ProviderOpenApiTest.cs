using Microsoft.AspNetCore.Mvc.Testing;
using System.IO;
using System.Threading.Tasks;
using Xunit;

namespace Provider.Tests
{
    public class ProviderOpenApiTest : IClassFixture<WebApplicationFactory<Program>>
    {
        private readonly WebApplicationFactory<Program> _factory;

        public ProviderOpenApiTest(WebApplicationFactory<Program> factory)
        {
            _factory = factory;
        }

        [Fact]
        public async Task GetProduct_ReturnsOk()
        {
            // Arrange
            var client = _factory.CreateClient();

            // Act
            var response = await client.GetAsync("/api/products/10");

            // Assert
            response.EnsureSuccessStatusCode();
            var content = await response.Content.ReadAsStringAsync();
            Assert.Contains("28 Degrees", content);
        }

        [Fact]
        public async Task GenerateOpenApiSpec()
        {
            // Arrange
            var client = _factory.CreateClient();

            // Act
            var response = await client.GetAsync("/swagger/v1/swagger.json");

            // Assert
            response.EnsureSuccessStatusCode();
            var content = await response.Content.ReadAsStringAsync();
            Assert.NotEmpty(content);

            // Save to file (root of the provider solution, for publishing)
            // Navigate up from bin/Debug/net8.0/ to samples/provider/
            var outputDir = "../../../../../oas";
            Directory.CreateDirectory(outputDir);
            await File.WriteAllTextAsync(Path.Combine(outputDir, "provider-oas.json"), content);
        }
    }
}
