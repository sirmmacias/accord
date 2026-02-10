using System;
using System.Net.Http;
using System.Threading.Tasks;
using Newtonsoft.Json;

namespace Consumer.ApiClient
{
    public class ProductsClient
    {
        private readonly HttpClient _client;

        public ProductsClient(HttpClient client)
        {
            _client = client;
        }

        public async Task<Product> GetProduct(int id)
        {
            var response = await _client.GetAsync($"/api/products/{id}");
            response.EnsureSuccessStatusCode();

            var content = await response.Content.ReadAsStringAsync();
            return JsonConvert.DeserializeObject<Product>(content);
        }
    }
}
