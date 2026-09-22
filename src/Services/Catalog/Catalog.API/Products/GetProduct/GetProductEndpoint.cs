
using Catalog.API.Products.CreateProduct;

namespace Catalog.API.Products.GetProduct
{
    //public record GetProductsRequest();

    public record GetProductResponse(IEnumerable<Product> Products);
    public class GetProductEndpoint : ICarterModule
    {
        public void AddRoutes(IEndpointRouteBuilder app)
        {
            app.MapGet("/products", async (ISender sender) =>
            {
                var query = new GetProductsQuery();
                var result = await sender.Send(query);
                var response = result.Adapt<GetProductResponse>();
                return Results.Ok(response);
            }).WithName("GetProduct")
                .Produces<CreateProductResponse>(StatusCodes.Status201Created)
                .ProducesProblem(StatusCodes.Status400BadRequest)
                .WithSummary("Get products")
                .WithDescription("Get products");
        }
    }
}
