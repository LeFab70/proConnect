// DTO pour retourner uniquement l'ID d'une entité créée ou mise à jour, utilisé dans les méthodes Create et Update des services pour fournir une réponse standardisée contenant l'ID de l'entité concernée.
namespace backend.Dtos.Common;

public class IdResponseDto
{
    public long Id { get; set; } // Propriété pour stocker l'ID de l'entité concernée
}