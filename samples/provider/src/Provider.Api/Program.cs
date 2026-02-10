var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Configure the HTTP request pipeline.
// Always enable Swagger for sample purposes
app.UseSwagger();
app.UseSwaggerUI();

app.UseHttpsRedirection();

app.MapGet("/api/products/{id}", (int id) =>
{
    if (id == 10)
    {
        return Results.Ok(new Product(10, "28 Degrees", "Credit Card"));
    }
    return Results.NotFound();
})
.WithName("GetProduct");

app.Run();

public record Product(int Id, string Name, string Type);

public partial class Program { }
